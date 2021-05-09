### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| BEP165.sol | 8c65f0c22d662697c183a06f5a1c0a9718b41a69 |
| interfaces/IBEP1155.sol | da39a3ee5e6b4b0d3255bfef95601890afd80709 |
| interfaces/IBEP1155Metadata.sol | b7f4363dccad95088405fce125635c8372270911 |
| interfaces/IBEP165.sol | 00b873483b562ab9a2051d64e00fe83c564ed722 |
| utils/Address.sol | 34881ef2e45c0b515a3c7070394be84269e35584 |
| utils/Context.sol | b205aa73169d41ef032d0be51c26b3a881692500 |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **BEP165** | Implementation | IBEP165 |||
| └ | supportsInterface | Public ❗️ |   |NO❗️ |
||||||
| **IBEP1155Metadata** | Interface |  |||
||||||
| **IBEP165** | Interface |  |||
| └ | supportsInterface | External ❗️ |   |NO❗️ |
||||||
| **Address** | Library |  |||
| └ | isContract | Internal 🔒 |   | |
| └ | sendValue | Internal 🔒 | 🛑  | |
| └ | functionCall | Internal 🔒 | 🛑  | |
| └ | functionCall | Internal 🔒 | 🛑  | |
| └ | functionCallWithValue | Internal 🔒 | 🛑  | |
| └ | functionCallWithValue | Internal 🔒 | 🛑  | |
| └ | functionStaticCall | Internal 🔒 |   | |
| └ | functionStaticCall | Internal 🔒 |   | |
| └ | functionDelegateCall | Internal 🔒 | 🛑  | |
| └ | functionDelegateCall | Internal 🔒 | 🛑  | |
| └ | _verifyCallResult | Private 🔐 |   | |
||||||
| **Context** | Implementation |  |||
| └ | _msgSender | Internal 🔒 |   | |
| └ | _msgData | Internal 🔒 |   | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
