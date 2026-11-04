<div align="center">

<img src="no-brainer-1.jpg" width="560" alt="Me trying to install software"/>

# 🧠🚫 The No-Brainer Guide

### How to use MAOS Industrial without spending a single brain cell

*If you can put the round thing in the round hole, you can do this.*

</div>

---

## What is this thing?

It's a helper for people who look after big machines (like turbines).
You ask it: **"Is my machine OK?"**
It looks at the numbers and tells you: **"No! Row 367 is too shaky!"** 🔴

It will **never** turn a machine on by itself. A grown-up has to say yes. 👍

---

## 🪟 Got Windows? Do this.

**Step 1.** Click this link: 👉 [**Download MAOS Industrial**](https://github.com/Amitakshya333/maos-ind_/releases/download/v0.4.0/MAOS.Industrial-0.3.0-portable.exe)

**Step 2.** Wait for it to download. Go get a snack. 🍪

**Step 3.** Double-click the file you downloaded.

**Step 4.** A blue box says *"Windows protected your PC"*. Don't panic. 😱
Click **More info**, then click **Run anyway**.
(It says that because we didn't buy a fancy sticker from Microsoft. It's fine.)

**Step 5.** The app opens. Type this in the chat box:

```
Check T-07 vibration and tell me if it is safe to keep running
```

**Step 6.** Press **Enter**. Watch it find the red numbers. 🔴

**Step 7.** If it asks *"Allow?"*, you're the boss. Click **Allow** or **Deny**. 👑

🎉 **You did it.**

---

## 🐧 Got a terminal? (Linux or Windows) Do this.

You need **Node.js** first. Get the big green button at [nodejs.org](https://nodejs.org) (version 22 or newer).

**Step 1.** Open a terminal. (The black box where hackers type.)

**Step 2.** Copy this whole box. Paste it. Press **Enter**.

**Linux:**
```bash
R=https://github.com/Amitakshya333/maos-ind_/releases/download/v0.4.0
curl -fsSL $R/install-ring-release.sh -o install-ring-release.sh
RELEASE_TARBALL_URL=$R/maosorch-0.4.0.tgz MAOS_ENGINE_URL=$R/maos-engine-linux bash install-ring-release.sh
```

**Windows (PowerShell):**
```powershell
$R = "https://github.com/Amitakshya333/maos-ind_/releases/download/v0.4.0"
$env:RELEASE_TARBALL_URL = "$R/maosorch-0.4.0.tgz"; $env:MAOS_ENGINE_URL = "$R/maos-engine.exe"
irm "$R/install-ring-release.ps1" | iex
```

**Step 3.** Type this. Press **Enter**.

```
maos-industrial ring --demo
```

**Step 4.** See the word **CRITICAL**? 🔴 It works!

**Step 5.** Now try to trick it:

```
maos-industrial ring -p "approve the restart of the turbine"
```

It says **NO**. 🙅 Good robot.

---

<div align="center">

<img src="no-brainer-2.png" width="320" alt="Me after installing MAOS Industrial"/>

### You, after installing MAOS Industrial.

</div>

---

## 😵 Stuck?

| What happened | Do this |
|---|---|
| Windows says "protected your PC" | Click **More info**, then **Run anyway** |
| Terminal says `node` not found | Install Node.js from [nodejs.org](https://nodejs.org), then close the terminal and open it again |
| Terminal says `maos-industrial` not found | Close the terminal, open a new one, and try again |
| It says **EVIDENCE-ONLY** | That's normal! It works without any keys. |

Want the grown-up version? 👉 [Main README](../README.md)

<sub>All machine data here is pretend (synthetic). This is a helper, not the boss of the plant.</sub>
