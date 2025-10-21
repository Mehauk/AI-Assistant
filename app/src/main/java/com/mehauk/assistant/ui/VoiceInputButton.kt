package com.mehauk.assistant.ui

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.widget.Toast
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import androidx.core.content.ContextCompat

@Composable
fun VoiceInputButton(
    modifier: Modifier = Modifier,
    onResult: (String) -> Unit,
) {
    val context = LocalContext.current

    var isListening by remember { mutableStateOf(false) }
    var speechRecognizer: SpeechRecognizer? by remember { mutableStateOf(null) }

    // ✅ Pulsating animation using animateFloat, then converted to Dp
    val infiniteTransition = rememberInfiniteTransition(label = "pulse")
    val pulse by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = 1.3f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 600),
            repeatMode = RepeatMode.Reverse
        ),
        label = "pulseScale"
    )

    val buttonSize = if (isListening) (60.dp * pulse) else 60.dp

    Button(
        onClick = {
            if (!isListening) {
                if (ContextCompat.checkSelfPermission(
                        context,
                        Manifest.permission.RECORD_AUDIO
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    // ❗ Show a toast or log message; permissions must be granted beforehand
                    Toast.makeText(
                        context,
                        "Microphone permission required (grant in settings)",
                        Toast.LENGTH_SHORT
                    ).show()
                } else {
                    startListening(context, onResult, { isListening = it }, { speechRecognizer = it })
                }
            } else {
                speechRecognizer?.stopListening()
                isListening = false
            }
        },
        modifier = modifier.size(buttonSize)
    ) {
        Icon(
            painter = painterResource(
                if (isListening) android.R.drawable.ic_btn_speak_now
                else android.R.drawable.ic_secure
            ),
            contentDescription = "Voice input"
        )
    }
}

private fun startListening(
    context: Context,
    onResult: (String) -> Unit,
    setListening: (Boolean) -> Unit,
    setRecognizer: (SpeechRecognizer?) -> Unit
) {
    val recognizer = SpeechRecognizer.createSpeechRecognizer(context.applicationContext)
    setRecognizer(recognizer)

    val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
        putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
        putExtra(RecognizerIntent.EXTRA_LANGUAGE, "en-US")
        putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 3)
        putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
        putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_COMPLETE_SILENCE_LENGTH_MILLIS, 2500)
        putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_POSSIBLY_COMPLETE_SILENCE_LENGTH_MILLIS, 4000)
        putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_MINIMUM_LENGTH_MILLIS, 1500)
    }

    var lastPartial = ""
    var finalDelivered = false

    recognizer.setRecognitionListener(object : RecognitionListener {
        override fun onReadyForSpeech(params: Bundle?) {
            setListening(true)
        }

        override fun onBeginningOfSpeech() {}
        override fun onRmsChanged(rmsdB: Float) {}
        override fun onBufferReceived(buffer: ByteArray?) {}
        override fun onEndOfSpeech() {
            setListening(false)
        }

        override fun onError(error: Int) {
            setListening(false)
            if (!finalDelivered && lastPartial.isNotBlank()) {
                onResult(lastPartial)
                finalDelivered = true
            }
        }

        override fun onResults(results: Bundle?) {
            val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
            val finalResult = matches?.firstOrNull()?.trim().orEmpty()

            if (finalResult.isNotBlank()) {
                onResult(finalResult)
                finalDelivered = true
            } else if (lastPartial.isNotBlank() && !finalDelivered) {
                onResult(lastPartial)
                finalDelivered = true
            }
        }

        override fun onPartialResults(partialResults: Bundle?) {
            val partial = partialResults
                ?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                ?.firstOrNull()
                ?.trim()
                ?: return
            if (partial.isNotBlank()) {
                lastPartial = partial
            }
        }

        override fun onEvent(eventType: Int, params: Bundle?) {}
    })


    recognizer.startListening(intent)
}
