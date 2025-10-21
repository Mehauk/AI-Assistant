package com.mehauk.assistant.ui

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.mehauk.assistant.models.UniqueStringItem
import com.mehauk.assistant.services.GeminiService
import com.mehauk.assistant.ui._config.AppTheme
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@Composable
fun OverlayScreen(onClose: () -> Unit) {
    var isVisible by remember { mutableStateOf(false) }
    val coroutineScope = rememberCoroutineScope()
    var isTallMode by remember { mutableStateOf(false) }
    val animatedHeight by animateDpAsState(
        targetValue = if (isTallMode) 500.dp else 250.dp,
        animationSpec = tween(300),
        label = "height"
    )
    val scrimColor by animateColorAsState(
        targetValue = if (isVisible) Color.Black.copy(alpha = 0.32f) else Color.Transparent,
        animationSpec = tween(300),
        label = "scrim"
    )

    val listState = rememberLazyListState()

    val geminiService = GeminiService();

    var chatMessages by remember { mutableStateOf(listOf<UniqueStringItem>()) }


    LaunchedEffect(Unit) {
        isVisible = true
    }

    LaunchedEffect(chatMessages.size) {
        if (chatMessages.isNotEmpty()) {
            listState.animateScrollToItem(chatMessages.size - 1)
        }
    }

    AppTheme {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(scrimColor)
                .clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null
                ) {
                    coroutineScope.launch {
                        isVisible = false
                        delay(300) // Animation duration
                        onClose()
                    }
                },
            contentAlignment = Alignment.BottomCenter
        ) {
            AnimatedVisibility(
                visible = isVisible,
                enter = slideInVertically(
                    initialOffsetY = { it },
                    animationSpec = tween(300)
                ),
                exit = slideOutVertically(
                    targetOffsetY = { it },
                    animationSpec = tween(300)
                )
            ) {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable(
                            interactionSource = remember { MutableInteractionSource() },
                            indication = null
                        ) { /* do nothing */ },
                    shape = RoundedCornerShape(topStart = 16.dp, topEnd = 16.dp),
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(animatedHeight)
                            .padding(16.dp)
                    ) {
                        Column(
                            modifier = Modifier.weight(1f)
                        ) {
                            if (!isTallMode) {
                                MarkdownPreview("## AI-Assistant")
                            } else {
                                LazyColumn(
                                    modifier = Modifier
                                        .fillMaxSize()
                                        .padding(top = 16.dp),
                                    state = listState
                                ) {
                                    items(chatMessages, key = { it.id }) { message ->
                                        MarkdownPreview(message.content)
                                    }
                                }
                            }
                        }
                        VoiceInputButton(modifier = Modifier.align(Alignment.CenterHorizontally)) { recognizedText ->
                            if (recognizedText.isNotBlank()) {
                                if (!isTallMode) isTallMode = true
                                chatMessages = chatMessages + UniqueStringItem(recognizedText)
                                coroutineScope.launch {
                                    val res = geminiService.message(recognizedText)
                                    chatMessages = chatMessages + UniqueStringItem(res)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
