# JSP Web Shell

A lightweight JSP-based web shell for penetration testing and security assessments.

## Features

- **Remote Command Execution**: Execute system commands via web interface
- **Multi-Platform Support**: Windows (CMD/PowerShell) and Linux (SH)
- **Legacy Compatibility**: Works on Tomcat 5.0+ and Java 1.4+

## Deployment

### Option 1: Direct JSP Upload
1. Upload `cmd.jsp` to target Tomcat webapps directory
2. Access via: `http://target-server/cmd.jsp`

### Option 2: WAR File Deployment
1. Create WAR file: `jar -cvf cmd.war .`
2. Deploy WAR to Tomcat webapps directory
3. Access via: `http://target-server/cmd/cmd.jsp`

No additional configuration required for either method.

## Usage

### Command Execution
- Platform auto-detection with manual override
- Multi-line command support
- Real-time output display
- Cross-platform shell access

## Target Compatibility

- **Application Servers**: Tomcat 5.0-11.x, JBoss, WebLogic
- **Java Versions**: 1.4 through 21
- **Operating Systems**: Windows, Linux, Unix variants

- **Browsers**: All major browsers including legacy versions
