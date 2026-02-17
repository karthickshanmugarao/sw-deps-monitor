# Example App Architecture

1. ModuleA, ModuleB, and ModuleC are asynchronously running Queue Based State machine developed for different purposes. They should be independent of each other so that it can be reused in different projects.

2. There are separate Communication libraries that hold Queue References and Message Classes (Data Structures) meant to request actions and ack requests from another module.

3. ModuleA acts as master and can send Messages defined in ABComm.lvlib to ModuleB, and send Messages defined in ACComm.lvlib to ModuleC.

4. ModuleB and ModuleC should not communicate with each other at any time.

5. This design ensures each module can be unit tested with the Communication libraries.

6. This holds good as long as there are no cross linkings introduced between the modules.