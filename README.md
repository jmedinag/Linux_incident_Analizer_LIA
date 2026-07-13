# LIA - Linux Incident Analyzer
<pre>
      ___                   ___
     /\__\      ___        /\  \
    /:/  /     /\  \      /::\  \
   /:/  /      \:\  \    /:/\:\  \
  /:/  /       /::\__\  /::\~\:\  \
 /:/__/     __/:/\/__/ /:/\:\ \:\__\
 \:\  \    /\/:/  /    \/__\:\/:/  /
  \:\  \   \::/__/          \::/  /
   \:\  \   \:\__\          /:/  /
    \:\__\   \/__/         /:/  /
     \/__/                 \/__/

                Javier Medina 2026


</pre>

# Overview

**LIA (Linux Incident Analyzer)** is a lightweight diagnostic framework that helps engineers perform initial Linux incident analysis by collecting system evidence, evaluating health indicators, and providing operational recommendations.

LIA focuses on the first phase of incident response:

> Collect evidence → Analyze conditions → Recommend investigation steps


It helps investigate common Linux operational problems:

- High CPU usage
- Memory pressure
- Disk exhaustion
- Failed services
- Network issues
- System degradation


LIA is designed to support engineers during troubleshooting without automatically modifying the system.


---

# Key Features


## System Analysis

Automated analysis of critical Linux components:


| Component | Analysis |
|-----------|----------|
| CPU | Usage, load average, processes |
| Memory | RAM, swap, pressure indicators |
| Storage | Disk usage, filesystems, inodes |
| Processes | Resource consumption |
| Services | Failed systemd units |
| Network | Interface and connectivity status |


---

# Design Principles


## Evidence First

LIA collects information before recommending actions.


## Non-Invasive

No automatic remediation.
No configuration changes.
No destructive operations.


## Lightweight

Built using native Linux tools and Bash scripting.

## Knowledge Separation

Diagnostic logic is separated from operational knowledge, allowing continuous improvement without modifying the core engine.


---

# Architecture

             LIA Engine


                 |
                 v


      +-------------------+
      | Data Collection   |
      +-------------------+

                 |

                 v


      +-------------------+
      | Analysis Modules  |
      +-------------------+

                 |

                 v


      +-------------------+
      | Knowledge Engine  |
      +-------------------+

                 |

                 v


      +-------------------+
      | Recommendations   |
      +-------------------+



---

# Project Structure
incident-analyzer/

├── incident-check.sh

├── lib/
│ ├── cpu.sh
│ ├── memory.sh
│ ├── disk.sh
│ ├── network.sh
│ ├── services.sh
│ └── knowledge_engine.sh

├── knowledge/

├── docs/

├── images/

├── LICENSE

├── CHANGELOG.md

└── README.md



---

# Requirements


- Linux system
- Bash 4+
- Standard Linux utilities


Tested environments:

- Ubuntu
- Debian
- Rocky Linux
- AlmaLinux

# Installation


Clone the repository:


bash
git clone https://github.com/<username>/incident-analyzer.git

cd incident-analyzer

Make the script executable:
chmod +x incident-check.sh

Run LIA:

./incident-check.sh

For extended information:

sudo ./incident-check.sh


====================================
     Linux Incident Analyzer
              LIA
====================================


[OK] System information collected

[OK] CPU analysis completed

[OK] Memory analysis completed

[OK] Disk analysis completed

[OK] Network analysis completed

[OK] Service analysis completed


Analysis completed successfully.

example finding

CPU Usage: 94%

Status:
WARNING


Possible causes:

- High workload
- Resource saturation
- Runaway process


Recommendation:

Review top CPU consumers.
Roadmap
Current
Modular Bash architecture
System health analysis
Knowledge engine foundation
Diagnostic recommendations
Planned
JSON reports
HTML reports
Log analysis
Historical comparisons
Extended Linux distribution support
Future Vision
Local AI-assisted analysis
RAG-based troubleshooting
Incident knowledge correlation
Documentation

Additional documentation:

docs/

├── ARCHITECTURE.md

├── KNOWLEDGE_ENGINE.md

├── DEVELOPMENT.md

└── SECURITY.md

Contributing

Contributions are welcome.

Areas of interest:

New analysis modules
Linux troubleshooting knowledge
Documentation improvements
Testing

Please review:

CONTRIBUTING.md

before submitting changes.

Security

LIA follows a non-invasive approach:

No external data transmission
No automatic system changes
Local analysis only
License

LIA is released under the MIT License.

See:

LICENSE
<p align="center"> <b> LIA - Linux Incident Analyzer </b> <br>

Engineering better incident investigations, one system at a time.

</p>
# Installation


## Clone Repository


bash
git clone https://github.com/<username>/incident-analyzer.git

cd incident-analyzer
Set Permissions

Make the main script executable:

chmod +x incident-check.sh
Execute LIA

Run the analyzer:

./incident-check.sh

For extended system visibility:

sudo ./incident-check.sh
Usage Example

When executed, LIA performs a structured analysis:

Incident Detected

        |
        v

Evidence Collection

        |
        v

System Analysis

        |
        v

Issue Identification

        |
        v

Recommendations


Example:

========================================
        Linux Incident Analyzer
                 LIA
========================================


[INFO] Starting analysis...


[OK] System information collected

[OK] CPU analysis completed

[OK] Memory analysis completed

[OK] Disk analysis completed

[OK] Network analysis completed

[OK] Services analysis completed


Analysis completed successfully.

Example Findings
CPU Resource Pressure
CPU Usage:

92%


Status:

WARNING


Possible causes:

- High workload
- Resource saturation
- Runaway process


Recommendation:

Review active processes and workload behavior.

Disk Capacity Issue
Filesystem:

/


Usage:

95%


Status:

WARNING


Recommendation:

Review:

- Application logs
- Temporary files
- Old backups

Exit Codes

LIA provides exit codes for automation:

Code	Description
0	Analysis completed successfully
1	Execution error
2	Missing dependency
3	Permission issue
Documentation

Detailed technical documentation is available in:

docs/

├── ARCHITECTURE.md

├── KNOWLEDGE_ENGINE.md

├── INCIDENT_WORKFLOW.md

├── SECURITY.md

└── ROADMAP.md

Roadmap
Current Release

Implemented:

Modular Bash architecture
Linux system diagnostics
CPU analysis
Memory analysis
Disk analysis
Network analysis
Service analysis
Knowledge engine foundation
Future Improvements

Planned:

JSON and HTML reports
Extended log analysis
Historical incident comparison
Additional Linux distributions
Improved diagnostic rules
Long-Term Vision

Future versions aim to introduce:

Linux Telemetry

        +

Operational Knowledge

        +

Automation

        +

Local AI Assistance

        =

Intelligent Incident Analysis

Contributing

Contributions are welcome.

Possible contribution areas:

New analysis modules
Linux troubleshooting rules
Documentation improvements
Testing scenarios

Before contributing, review:

CONTRIBUTING.md
Security Principles

LIA follows a security-focused approach:

Local execution only
No external data transmission
No automatic remediation
No configuration changes
Non-destructive analysis

The engineer always maintains control over remediation decisions.

License

LIA is released under the MIT License.

See:

LICENSE

for complete details.

Acknowledgments

Inspired by:

Linux Administration practices
DevOps methodologies
Site Reliability Engineering principles
Incident Response workflows
Open Source communities
<p align="center"> <b> LIA - Linux Incident Analyzer </b> <br>

Engineering better incident investigations, one system at a time.

</p> ```
