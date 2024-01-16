package utilities

/// This validator is primarily a means of sanitizing inputs before storing them in our database.
/// We can't let the users send just *any* string, because it could be an attack.
/// We don't care if the validation rules are a little lax though.
/// Ultimately, it's up to our users to ensure the emails/phones are valid.
// TODO: update backend to use the same regexes!
class Validator {

    // one or more characters that are not `@`
    // @
    // one or more characters that are not `@`
    // .
    // one or more characters that are not `@`
    fun isEmail(input: String): Boolean {
        val emailRegex = Regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")
        return emailRegex.matches(input)
    }

    // is 1-25 characters long
    // contains only numbers and the characters `()[]-.*#+`
    fun isPhoneNumber(input: String): Boolean {
        val phoneRegex = Regex("^[0-9()\\[\\]\\-.*#+]{1,25}$")
        return phoneRegex.matches(input)
    }

    fun isName(input: String): Boolean {
        if (input.isEmpty() || input.length > 32) return false

        for (char in input) {
            if (!char.isLetterOrDigit() && !char.isWhitespace() && !char.isPunctuation()) {
                return false
            }
        }
        return true
    }

    // Extension function to check if a Char is punctuation.
    private fun Char.isPunctuation(): Boolean {
        val punctuationChars = "!\"#\$%&'()*+,-./:;<=>?@[\\]^_`{|}~"
        return this in punctuationChars
    }
}