package video.api.eco.flt.livestream.apivideolivestream

import android.content.Context
import androidx.constraintlayout.widget.ConstraintLayout

class LiveStreamView(context: Context): ConstraintLayout(context) {
    init {
        inflate(context, R.layout.fluter_livestream, this)
    }
}