To set the `SEPOLIA_PRIVATE_KEY` config variable using `hardhat-keystore`:

```shell
npx hardhat keystore set SEPOLIA_PRIVATE_KEY
```

After setting the variable, you can run the deployment with the Sepolia network:

## command to deploy the contract

```shell
npx hardhat ignition deploy --network testnet ignition/modules/PicknGet.ts
```

```shell
Deployed txn hash:
0x7e28dcc10fad7b6b66a8fc76f74881f52407fbfa20ccdd7b330c882deaef630d
```

## contract address
```shell
contract deployed to: 0x82B63E09E740302eb91116d7CC0E7039946Db134
```

```shell
See details in hashscan : 
 https://hashscan.io/testnet/address/0x82B63E09E740302eb91116d7CC0E7039946Db134
 ```


## command to get the metadata
```shell
solc --bin --abi --metadata -o ./contracts ./contracts/PicknGet.sol ./contracts/Admin.sol ./contracts/Product.sol ./contracts/User.sol ./contracts/library/ItemLib.sol
```

## command to get the metadata for stack too deep error
```shell
solc --bin --abi --metadata --via-ir -o ./contracts ./contracts/PicknGet.sol ./contracts/Admin.sol ./contracts/Product.sol ./contracts/User.sol ./contracts/library/ItemLib.sol 
```

## contract abi
```shell
https://hashscan.io/testnet/contract/0.0.7110475/abi
```

##
```shell
Deploying contract...
Product contract deployed at: 0xBB5eD93236774816D11ba68D80923a8eCf27C484
Product Deployment Tx Hash: 0x7da18a40cc71243d1aa07a50b655572b7cac996f9c835e6623a48a12bd024039

See product details in hashscan : 
 https://hashscan.io/testnet/address/0xBB5eD93236774816D11ba68D80923a8eCf27C484 
 ```

 ## Product contract abi
 ```shell
 https://hashscan.io/testnet/contract/0.0.7110490/abi
 ```



