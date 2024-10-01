package video.api.flutter.livestream.utils

/**
 * Add a slash at the end of a [String] only if it is missing.
 *
 * @return the given string with a trailing slash.
 */
fun String.addTrailingSlashIfNeeded(): String {
    return if (this.endsWith("/")) this else "$this/"
}


