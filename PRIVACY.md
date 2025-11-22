# Cicada Actigraphy Suite - Privacy Policy

**Last Updated:** November 19, 2025

## 1. Overview

Cicada Actigraphy Suite ("Cicada", "the Software") is an open-source desktop application designed for researchers and clinicians to analyze actigraphy data for sleep-wake pattern assessment. This Privacy Policy explains how your data is handled when using Cicada.

## 2. Data controller

Cicada is developed and maintained by Rick Wassing at the Woolcock Institute of Medical Research, Sydney, Australia.

## 3. Data processing

### 3.1 What data does Cicada process?

Cicada processes the following types of data:

### 3.1.1 Wearable device data:

Including, but not limited to:

- Activity measurements from wearable devices (accelerometer data)
- Light exposure data
- Temperature data
- Pulse-rate or heart-rate data
- Participant-rated data from questionnaires or diaries
- Device metadata (device ID, recording dates, firmware version)

### 3.1.2. Application settings:

- User preferences and application configuration
- Report templates and styling preferences

### 3.1.3 Patient/research participant data (optional by explicit data entry):

Cicada allows users to enter personal information, including:

- Name, ID, date of birth, and other personal information
- Clinical notes and interpretations
- Referring physician information

### 3.1.4. Telemetry and usage-data (optional with consent):

- User registration information (name, email address, institution)
- Subscription preferences for updates
- Session tracking data (app start/stop, session IDs)
- Error messages and diagnostic information (stack traces, error severity)
- System information (operating system, MATLAB version, Cicada version)
- Feature usage statistics

**IMPORTANT:** Telemetry data is ONLY collected if you consent during registration or through the registration settings. You can change your consent at any time via the "Edit registration" option in the Help menu.

## 3.2 How Is Data Stored?

### 3.2.1 Wearable device data, application settings, and patient/research-participant data (local storage only)

**ALL data described in 3.1.1, 3.1.2 and 3.1.3 is stored exclusively on your local computer.**

The Software does NOT:

- Upload patient/participant data to cloud servers
- Transmit device data (actigraphy, light, temperature, etc.) over the internet
- Share clinical notes or report content with third parties
- Store any patient/research data on external servers

**Telemetry Data described in 3.1.4 is stored on Microsoft Cloud Storage**

If you consent to share telemetry data, the following applies:

- **What is transmitted:** Only the usage and diagnostic data listed in 3.1.4 above
- **What is NEVER transmitted:** Patient data, device measurements, clinical notes, report content, or any participant information described in 3.1.1, 3.1.2, and 3.1.3.
- **Where it's stored:** Microsoft Power Automate (Flow) processes the data and stores it in SharePoint Lists
- **Who has access:** Only Rick Wassing (rick.wassing@woolcock.org.au)
- **Security:** Protected by Microsoft's enterprise-grade security with 2-factor authentication
- **Purpose:** Software improvement, usage statistics, understanding user needs, and grant applications

**Your responsibility:** As a local application, YOU are responsible for:

- Securing the computer where Cicada is installed
- Backing up your data files
- Ensuring compliance with local data protection regulations (HIPAA, GDPR, etc.)
- Properly disposing of data when no longer needed

## 4. Data formats

Data is stored in:

- MATLAB `.mat` files for datasets
- JSON files for configuration
- PDF files for exported reports

## 5. Data Sharing and Third Parties

### 5.1 Wearable device data, application settings, and patient/research-participant data

Cicada does NOT share your patient, clinical, or research data with third parties. Your data remains on your computer.

### 5.2 Telemetry data

If you consent to share telemetry data:

1. **Data recipient:** Telemetry data is sent to Rick Wassing at Woolcock Institute of Medical Research
2. **No third-party sharing:** Telemetry data is not shared with or sold to third parties
3. **No marketing:** Your contact information will not be used for marketing purposes (unless you separately consent to receive updates)
4. **Aggregated statistics:** Anonymous, aggregated statistics may be used in presentations, publications, or grant applications
5. **No patient/research-participant data:** Telemetry NEVER includes patient, participant, or clinical information

## 6. User rights

### 6.1. Wearable device data, application settings, and patient/research-participant data

As Cicada stores data locally on your computer, you have complete control:

- **Access:** You can access all your data files at any time
- **Modification:** You can modify or delete data through the application or file system
- **Portability:** Your data files are in standard formats and can be moved/copied
- **Deletion:** You can delete data files directly from your computer

### 6.2. Telemetry data

If you have consented to share telemetry data:

- **Consent withdrawal:** You can withdraw consent at any time via "Edit registration" in the Help menu
- **Future data:** Withdrawing consent prevents future telemetry collection
- **Past data:** Data already collected cannot be deleted from storage (minimum 15-year retention for research integrity)
- **Access request:** Contact rick.wassing@woolcock.org.au to request information about what telemetry data has been collected

## 7. Data security

### 7.1. Your responsibility

Since Cicada is a local application, data security depends on:

1. **Computer security:**

   - Use strong passwords for your computer account
   - Enable disk encryption if handling sensitive data
   - Keep your operating system and security software updated
   - Physically secure computers containing patient data

2. **Access control:**

   - Restrict access to the computer and data files
   - Log out when not using the computer
   - Follow your institution's data security policies

3. **Backups:**
   - Regularly back up your data files
   - Secure backup storage appropriately
   - Test backup restoration procedures

### 7.2. Software security

We implement security best practices in Cicada's development:

- Regular code reviews
- Security vulnerability monitoring
- Timely security updates
- Open-source code repository to facilitate peer-review

## 8. Compliance with regulations

### 8.1 Research data

If using Cicada for research:

1. Obtain appropriate ethical approval from your institution
2. Follow procedures outlined in the approved protocol, participant information and informed consent documents
3. Follow institutional governace procedures
4. De-identify data as required by your ethics approval
5. Store data according to your institution's research data management policy
6. Retain data for the required period per regulations

### 8.2. Healthcare data regulations

If you use Cicada for clinical purposes, you must ensure compliance with applicable regulations:

- **HIPAA (United States):** If you are a covered entity, ensure your computer systems and practices comply with HIPAA requirements
- **GDPR (European Union):** Follow GDPR requirements for processing personal health data
- **Australian Privacy Principles:** Comply with APP requirements if applicable
- **Other Local Regulations:** Follow all applicable local data protection laws

**Important:** Cicada provides the tool, but YOU are responsible for ensuring compliant use.

## 9. Data retention

### 9.1. Wearable device data, application settings, and patient/research-participant data

You control retention of all patient/clinical/research data on your computer. Follow your institution's data retention policies.

### 9.2. Telemetry data

If you consented to share telemetry:

- **Retention period:** Minimum 15 years, no maximum limit
- **Purpose:** Long-term research on software usage patterns, grant reporting, software improvement
- **Cannot be deleted:** Due to research integrity requirements, telemetry data cannot be deleted upon request
- **Withdrawal effect:** Withdrawing consent stops future collection but does not delete historical data

## 10. Changes to this privacy policy

This Privacy Policy may be updated periodically:

- Updates will be published in the software repository
- Significant changes will be announced in release notes
- Continued use of Cicada constitutes acceptance of updates

## 11. Contact information

For privacy-related questions or concerns:

- **Email:** cicadaactigraphysuite@gmail.com
- **Documentation:** https://cicada-actigraphy-suite.readthedocs.io
- **GitHub repository:** https://github.com/rickwassing/Cicada

## Disclaimer

This privacy policy is provided for informational purposes. As an open-source, locally-run application, Cicada cannot enforce data protection measures. Users are solely responsible for ensuring their use of the Software complies with all applicable laws and regulations.

## Software license

Cicada is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0). See LICENSE file for details.

---

**Version:** 1.0  
**Effective Date:** November 19, 2025
