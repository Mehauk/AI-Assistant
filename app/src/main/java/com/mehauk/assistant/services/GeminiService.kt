package com.mehauk.assistant.services

import com.mehauk.assistant.BuildConfig
import fuel.Fuel
import fuel.post
import kotlinx.io.readString

class GeminiService {
    companion object {
        private const val GEMINI_API_KEY = BuildConfig.GEMINI_API_KEY
        private const val MODEL_ID = "gemini-flash-latest"
        private const val GENERATE_CONTENT_API = "streamGenerateContent"
        private const val URL = "https://generativelanguage.googleapis.com/v1beta/models/" +
                "${MODEL_ID}:${GENERATE_CONTENT_API}?key=${GEMINI_API_KEY}"

    }
    suspend fun message(text: String): String {
        return Fuel.post(URL, body =
        "{\n" +
        "    \"contents\": [\n" +
        "      {\n" +
        "        \"role\": \"user\",\n" +
        "        \"parts\": [\n" +
        "          {\n" +
        "            \"text\": \"${text}\"\n" +
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
    }
}