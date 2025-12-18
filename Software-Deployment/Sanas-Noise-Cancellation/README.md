# Sanas AI - Automated Mass Deployment 

## Project Context
**Goal:** Deploy "Sanas" (Noise Cancellation Software) to 60+ workstations to improve call quality.

## The Problem
The software installer provided by the vendor was not designed for automated Enterprise deployment. It required a human to manually type a license key on every single computer to finish the installation.

* **Time consuming:** Manual installation took ~10 minutes per agent.
* **Automation blocker:** Standard deployment tools (like PDQ Deploy) failed because they could not interact with the manual pop-up window.

## The Solution
I engineered a "Zero-Touch" solution using **PowerShell** to fully automate the process, removing the need for human intervention.

### How it works:
1.  **Silent Install:** The script forces the installer to run in the background without showing any windows.
2.  **Smart Detection:** Since the installation path varied between computers, I wrote a logic script that scans the Windows Registry to automatically find where the software was installed.
3.  **Auto-Activation:** The script injects the License Key directly into the system once the path is verified.

## Business Impact
* **Efficiency:** Reduced installation time from **10 minutes** to **30 seconds** per machine.
* **Reliability:** Eliminated human error (typos) during key entry.
* **Scalability:** The solution is now ready to be deployed to hundreds of computers simultaneously via PDQ Deploy.

---
*Note: License keys and sensitive data have been sanitized for security.*