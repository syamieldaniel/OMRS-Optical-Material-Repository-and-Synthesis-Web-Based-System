package com.omrs.util;

import java.util.regex.Pattern;

public class EmailValidator {
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
            "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$",
            Pattern.CASE_INSENSITIVE);

    private EmailValidator() {}

    public static boolean isValid(String email) {
        return email != null
                && email.length() <= 254
                && EMAIL_PATTERN.matcher(email.trim()).matches();
    }
}
