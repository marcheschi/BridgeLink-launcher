package com.innovarhealthcare.launcher;

import com.github.javakeyring.Keyring;
import com.github.javakeyring.PasswordAccessException;

import java.util.Base64;
import java.util.Optional;

/**
 * Stores the data encryption key in the operating system keystore when one is
 * available (Windows Credential Manager, macOS Keychain, Linux GNOME/KDE
 * keyring) through the {@code java-keyring} library.
 *
 * <p>The OS keystore binds the key to the user account instead of the machine
 * (the file-based fallback derives the wrapping key from machine facts), which
 * makes backups and profile copies useless to an attacker without the user's
 * session. Availability is probed once; every failure degrades silently to the
 * {@code .bridgekey} file mechanism so headless/unsupported environments keep
 * working unchanged.
 */
final class KeyringStore {

    private static final String SERVICE = "BridgeLinkLauncher";
    private static final String ACCOUNT = "data-key";

    private static volatile Boolean available;
    /** Test hook: when false, the keystore is treated as unavailable. */
    private static volatile boolean enabled = true;

    private KeyringStore() {
    }

    /** Package-private: lets unit tests force the file-based fallback. */
    static void setKeyringEnabledForTesting(boolean value) {
        enabled = value;
        available = null; // re-probe on next use
    }

    /**
     * @return true when an OS keystore backend can be created on this platform.
     */
    static boolean isAvailable() {
        if (!enabled) {
            return false;
        }
        Boolean b = available;
        if (b != null) {
            return b;
        }
        synchronized (KeyringStore.class) {
            if (available == null) {
                try (Keyring ignored = Keyring.create()) {
                    available = true;
                } catch (Throwable t) {
                    available = false;
                }
            }
            return available;
        }
    }

    /**
     * Stores the raw key material. Keys are base64-encoded because keystore
     * values are strings.
     *
     * @return true when the key was stored successfully.
     */
    static boolean save(byte[] key) {
        try (Keyring kr = Keyring.create()) {
            kr.setPassword(SERVICE, ACCOUNT, Base64.getEncoder().encodeToString(key));
            return true;
        } catch (Throwable t) {
            return false;
        }
    }

    /**
     * @return the stored key material, or empty when absent/unavailable.
     */
    static Optional<byte[]> load() {
        try (Keyring kr = Keyring.create()) {
            try {
                String stored = kr.getPassword(SERVICE, ACCOUNT);
                if (stored == null || stored.isEmpty()) {
                    return Optional.empty();
                }
                return Optional.of(Base64.getDecoder().decode(stored));
            } catch (PasswordAccessException e) {
                return Optional.empty(); // not stored yet
            }
        } catch (Throwable t) {
            return Optional.empty();
        }
    }
}
