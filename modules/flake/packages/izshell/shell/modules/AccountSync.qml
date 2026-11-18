import QtQuick
import Quickshell
import qs.data

// Copies the profile picture into AccountsService, the system-wide account
// picture the greeter can read (it runs as its own user and can't see ~).
Scope {
  readonly property string picture: Config.get("general.profile_picture")

  function push(): void {
    if (picture === "") return;
    Quickshell.execDetached(["sh", "-c",
      'p=$(busctl --system call org.freedesktop.Accounts /org/freedesktop/Accounts org.freedesktop.Accounts FindUserByName s "$USER" | cut -d\\" -f2)'
      + ' && busctl --system call org.freedesktop.Accounts "$p" org.freedesktop.Accounts.User SetIconFile s "$1"',
      "sh", picture]);
  }

  onPictureChanged: push()
  Component.onCompleted: push()
}
