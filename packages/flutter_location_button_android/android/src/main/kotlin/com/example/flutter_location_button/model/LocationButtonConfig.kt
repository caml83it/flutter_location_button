package com.example.flutter_location_button.model

/**
 * Encapsulates style and layout configuration for the LocationButton.
 * Extracted into the model layer to separate parsing logic from view rendering.
 */
data class LocationButtonConfig(
    val textType: Int? = null,
    val backgroundColor: Int? = null,
    val foregroundColor: Int? = null,
    val cornerRadius: Float,
    val strokeColor: Int? = null,
    val strokeWidth: Int? = null,
) {
    companion object {
        // Material 3 pill / stadium shape default radius (1000dp)
        private const val DEFAULT_CIRCLE_RADIUS_DP = 1000f

        fun from(args: Map<*, *>?, density: Float): LocationButtonConfig {
            val cornerRadiusNum = (args?.get("cornerRadius") as? Number)
                ?: (args?.get("borderRadius") as? Number)

            val radius = if (cornerRadiusNum != null) {
                cornerRadiusNum.toFloat() * density
            } else {
                DEFAULT_CIRCLE_RADIUS_DP * density
            }

            val strokeWidthPx = (args?.get("strokeWidth") as? Number)?.let {
                (it.toFloat() * density).toInt()
            }

            return LocationButtonConfig(
                textType = (args?.get("textType") as? Number)?.toInt(),
                backgroundColor = (args?.get("backgroundColor") as? Number)?.toInt(),
                foregroundColor = (args?.get("foregroundColor") as? Number)?.toInt(),
                cornerRadius = radius,
                strokeColor = (args?.get("strokeColor") as? Number)?.toInt(),
                strokeWidth = strokeWidthPx,
            )
        }
    }
}
