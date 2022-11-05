#!/bin/bash

API="https://api.telegram.org/bot$BOT_TOKEN"
tg() {
	if [[ ! -z "$BOT_TOKEN" ]]; then
  case $1 in
	--editmsg | --editmarkdownv2msg)
		local PARAM=$1
		shift
		local CHAT_ID=$1
		local MSG_ID=$2
		local NEW_TEXT=$3
		if [[ "$PARAM" =~ "--editmarkdownv2msg" ]]; then
			curl -s "$API/editMessageText" -d "chat_id=$CHAT_ID" -d "message_id=$MSG_ID" -d "text=$NEW_TEXT" -d "parse_mode=MarkdownV2" | jq .
		else
			curl -s "$API/editMessageText" -d "chat_id=$CHAT_ID" -d "message_id=$MSG_ID" -d "text=$NEW_TEXT" | jq .
		fi
		;;
		--editmsgurl)
		local PARAM=$1
		shift
		local CHAT_ID=$1
		local MSG_ID=$2
		local NEW_TEXT=$3
		curl -s "$API/editMessageText" -F "chat_id=$CHAT_ID" -F "message_id=$MSG_ID" -F "text=$NEW_TEXT" | jq .
		;;	
  --editmsghtml)
		shift
		local CHAT_ID=$1
		local MSG_ID=$2
		local MSG=$3
		local RESULT=$(curl -s "$API/editMessageText" --data "chat_id=$CHAT_ID&message_id=$MSG_ID&text=$MSG&parse_mode=HTML&disable_web_page_preview=True" | jq .)
		SENT_MSG_ID=$(echo "$RESULT" | jq '.result | .message_id')
		;;
	--sendmsg)
		shift
		local CHAT_ID=$1
		local MSG=$2
		local RESULT=$(curl -s "$API/sendMessage" -d "chat_id=$CHAT_ID" -d "text=$MSG")
		SENT_MSG_ID=$(echo "$RESULT" | jq '.result | .message_id')
		;;
	--sendmarkdownv2msg)
		shift
		local CHAT_ID=$1
		local MSG=$2
		local RESULT=$(curl -s "$API/sendMessage" -d "chat_id=$CHAT_ID" -d "parse_mode=MarkdownV2" -d "text=$MSG")
		SENT_MSG_ID=$(echo "$RESULT" | jq '.result | .message_id')
		;;
	--replymsg)
		shift
		local CHAT_ID=$1
		local MSG_ID=$2
		local MSG=$3
		local RESULT=$(curl -s "$API/sendMessage" -d "chat_id=$CHAT_ID" -d "reply_to_message_id=$MSG_ID" -d "text=$MSG" | jq .)
		SENT_MSG_ID=$(echo "$RESULT" | jq '.result | .message_id')
		;;
	--replyfile)
		shift
		local CHAT_ID=$1
		local MSG_ID=$2
		local MSG=$3
		local RESULT=$(curl -s "$API/sendDocument" -F "chat_id=$CHAT_ID" -F "reply_to_message_id=$MSG_ID" -F "document=@\"$MSG\"" | jq .)
		SENT_MSG_ID=$(echo "$RESULT" | jq '.result | .message_id')
		;;
	--replymsghtml)
		shift
		local CHAT_ID=$1
		local MSG_ID=$2
		local MSG=$3
		local RESULT=$(curl -s "$API/sendMessage" --form "chat_id=$CHAT_ID" --form "reply_to_message_id=$MSG_ID" --form "text=$MSG" | jq .)
		SENT_MSG_ID=$(echo "$RESULT" | jq '.result | .message_id')
		;;
	--replymsgmarkdown)
		shift
		local CHAT_ID=$1
		local MSG_ID=$2
		local MSG=$3
		local RESULT=$(curl -s "$API/sendMessage" -d "chat_id=$CHAT_ID" -d "reply_to_message_id=$MSG_ID" --data-urlencode "text=$MSG" | jq .)
		SENT_MSG_ID=$(echo "$RESULT" | jq '.result | .message_id')
		;;
	--replymarkdownv2msg)
		shift
		local CHAT_ID=$1
		local MSG_ID=$2
		local MSG=$3
		local RESULT=$(curl -s "$API/sendMessage" -d "chat_id=$CHAT_ID" -d "reply_to_message_id=$MSG_ID" -d "text=$MSG" -d "parse_mode=MarkdownV2" | jq .)
		SENT_MSG_ID=$(echo "$RESULT" | jq '.result | .message_id')
		echo "$RESULT"
		;;
	--delmsg)
		shift
		local CHAT_ID=$1
		local MSG_ID=$2
		curl -s "$API/deleteMessage" -d "chat_id=$CHAT_ID" -d "message_id=$MSG_ID" | jq .
		;;
	--sendsticker | --replysticker)
		local PARAM=$1
		shift
		local CHAT_ID=$1
		local FILE_ID=$2
		if [[ "$PARAM" =~ "--replysticker" ]]; then
			local MSG_ID=$2
			local FILE_ID=$3
			curl "$API/sendSticker" -d "chat_id=$CHAT_ID" -d "sticker=$FILE_ID" -d "reply_to_message_id=$MSG_ID" | jq .
		else
			curl "$API/sendSticker" -d "chat_id=$CHAT_ID" -d "sticker=$FILE_ID" | jq .
		fi
		;;
	--fwdmsg | --cpmsg)
		local PARAM=$1 # Save this to check for --cpmsg
		shift
		local FROM=$1
		local TO=$2
		local MSG_ID=$3
		if [ "$PARAM" = "--cpmsg" ]; then
			local MODE=copyMessage
		else
			local MODE=forwardMessage
		fi
		curl "$API/$MODE" -d "from_chat_id=$FROM" -d "chat_id=$TO" -d "message_id=$MSG_ID"
		;;
	--pinmsg)
		shift
		local CHAT_ID=$1
		local MSG_ID=$2
		curl "$API/pinChatMessage" -d "chat_id=$CHAT_ID" -d "message_id=$MSG_ID"
		;;
	--unpinmsg)
		shift
		local CHAT_ID=$1
		local MSG_ID=$2
		curl "$API/unpinChatMessage" -d "chat_id=$CHAT_ID" -d "message_id=$MSG_ID"
		;;
	esac
  else 
  echo "Bot token not found, skipping"
  fi
}
