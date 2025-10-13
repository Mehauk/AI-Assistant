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
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
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
import androidx.compose.ui.text.TextLinkStyles
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.dp
import com.mikepenz.markdown.m3.Markdown
import com.mikepenz.markdown.model.rememberMarkdownState
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

    val markdownState = rememberMarkdownState(
    """
    # Hello Markdown

    This is a simple markdown example with:

    - Bullet points
    - **Bold text**
    - *Italic text*
    `and code`
    
    ```
    code block
    ```

    [Check out this link](https://github.com/mikepenz/multiplatform-markdown-renderer)
    """.trimIndent())


    LaunchedEffect(Unit) {
        isVisible = true
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
                        ) { isTallMode = !isTallMode },
                    shape = RoundedCornerShape(topStart = 16.dp, topEnd = 16.dp),
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(animatedHeight)
                            .padding(16.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Markdown(markdownState)
                    }
                }
            }
        }
    }
}
