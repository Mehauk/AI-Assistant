package com.mehauk.assistant.models

data class UniqueStringItem(
    val content: String,
    val id: String = java.util.UUID.randomUUID().toString(), // Auto-generate a unique ID
)