# Dell Boomi API calls with Powershell
This scripts contains functions that call the Dell Boomi API to run a process.  The initial script does API calls to start processes in a Dell Boomi environment.  Some work will be required to get it working (authentication tokens etc).

# Prerequisites
* Powershell v5.1
* <a href url="https://help.boomi.com/bundle/integration/page/c-atm-Getting_started_with_API_b5110f51-d535-4bd2-978f-26152036870e.html">Dell Boomi API v1</a>

# Instructions
Before you can start using this script you will need to obtain your "accountId" and "atomId" from your Dell Boomi account.  Below is a list of script parameters and their usage:

* <b>User</b> - Dell Boomi user
* <b>Password</b> - Dell Boomi password
* <b>AccountId</b> - Dell Boomi AccountId
* <b>AtomId</b> - Dell Boomi AtomId
* <b>ProcessName</b> - Process to start on Dell Boomi
* <b>ProcessProperties</b> - Any additional properties to pass to the process when executing
* <b>WaitTime</b> - How long between checks (in seconds) to poll for the status of the process completion

# Disclaimer
No Support and No Warranty are provided by SMA Technologies for this project and related material. The use of this project's files is on your own risk.

SMA Technologies assumes no liability for damage caused by the usage of any of the files offered here via this Github repository.

# License
Copyright 2020 SMA Technologies

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

# Contributing
We love contributions, please read our [Contribution Guide](CONTRIBUTING.md) to get started!

# Code of Conduct
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v2.0%20adopted-ff69b4.svg)](code-of-conduct.md)
SMA Technologies has adopted the [Contributor Covenant](CODE_OF_CONDUCT.md) as its Code of Conduct, and we expect project participants to adhere to it. Please read the [full text](CODE_OF_CONDUCT.md) so that you can understand what actions will and will not be tolerated.
