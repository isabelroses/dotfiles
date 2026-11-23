import QtQuick
import qs.services

// Password prompt for the Wi-Fi join attempt in Networking. Used as a stacked
// card in quick settings, or inside a modal when that is closed.
PasswordPrompt {
  icon: "network-wireless-encrypted-symbolic"
  title: Networking.joinTarget?.name ?? ""
  subtitle: "Password required"
  message: Networking.joinError !== "" ? "Connection failed: " + Networking.joinError : ""
  error: Networking.joinError !== ""
  busy: Networking.joinState === "connecting"
  confirmText: "Connect"
  busyText: "Connecting…"
  onCancelled: Networking.cancel()
  onSubmitted: (password) => Networking.submit(password)
}
