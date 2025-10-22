package com.mehauk.assistant.models


enum class ChatRole(val role: String) {
    USER("user"),
    ASSISTANT("assistant"),
}
data class ChatMessage(
    val role: ChatRole,
    val content: String,
    val id: String = java.util.UUID.randomUUID().toString(), // Auto-generate a unique ID
)