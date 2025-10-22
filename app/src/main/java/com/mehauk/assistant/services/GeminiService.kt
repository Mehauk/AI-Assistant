package com.mehauk.assistant.services

import com.mehauk.assistant.BuildConfig
import com.mehauk.assistant.models.ChatMessage
import com.mehauk.assistant.models.ChatRole
import fuel.Fuel
import fuel.post
import kotlinx.io.readString
import org.json.JSONArray

class GeminiService {
    companion object {
        private const val GEMINI_API_KEY = BuildConfig.GEMINI_API_KEY
        private const val MODEL_ID = "gemini-flash-latest"
        private const val GENERATE_CONTENT_API = "streamGenerateContent"
        private const val URL = "https://generativelanguage.googleapis.com/v1beta/models/" +
                "${MODEL_ID}:${GENERATE_CONTENT_API}?key=${GEMINI_API_KEY}"

    }
    suspend fun message(chatMessage: ChatMessage, conversationHistory: List<ChatMessage>): ChatMessage {
        val response = Fuel.post(URL, body =
            "{\n" +
                    "    \"contents\": [\n" +
                    "      {\n" +
                    "        \"role\": \"user\",\n" +
                    "        \"parts\": [\n" +
                    "          {\n" +
                    "            \"text\": \"${chatMessage.content}\"\n" +
                    "          },\n" +
                    "        ]\n" +
                    "      },\n" +
                    "    ],\n" +
                    "    \"generationConfig\": {\n" +
                    "      \"thinkingConfig\": {\n" +
                    "        \"thinkingBudget\": -1,\n" +
                    "      },\n" +
                    "    },\n" +
                    "}"
        ).source.readString();

        val result = JSONArray(response)

        var message = ""

        for (i in 0 until result.length()) {
            val obj = result.getJSONObject(i)
            val candidate = obj.getJSONArray("candidates").getJSONObject(0)
            val parts = candidate.getJSONObject("content").getJSONArray("parts")
            for (j in 0 until parts.length()) {
                val part = parts.getJSONObject(j)
                message += part.getString("text")
            }
        }

        return ChatMessage(ChatRole.ASSISTANT, message)
    }
}