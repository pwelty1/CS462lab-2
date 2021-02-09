ruleset sms_app {
    meta {
      use module com.twilio alias twilio
        with
          account_sid = meta:rulesetConfig{"account_sid"}
          authtoken = meta:rulesetConfig{"authtoken"}
      shares lastResponse, messages
    }
    global {
        lastResponse = function() {
          {}.put(ent:lastTimestamp,ent:lastResponse)
        }
        messages = function() {
            twilio:messages()
        }
    }
    rule send_message {
        select when message new
          messageContent re#(.+)#
          phone_number re#(.+)#
          setting(messageContent,phone_number)
        twilio:sendMessage(phone_number,messageContent) setting(response)
        fired {
          ent:lastResponse := response
          ent:lastTimestamp := time:now()
          raise sms event "sent" attributes event:attrs
        }
      }
  }