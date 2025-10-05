import {
  Client,
  PrivateKey,
  TokenCreateTransaction,
  TokenSupplyType
} from "@hashgraph/sdk";
import dotenv from "dotenv"

dotenv.config();

async function createToken() {
    const operatorId  = process.env.OPERATOR_ID;
    const operatorKey = process.env.OPERATOR_KEY;

    const client = Client.forTestnet().setOperator(operatorId, operatorKey);

    const supplyKey = PrivateKey.generateECDSA();  
    const adminKey  = supplyKey;   

    const transaction = new TokenCreateTransaction()
    .setTokenName("EcoToken")        
    .setTokenSymbol("ETK")
    .setDecimals(2)                    // 100 = 1.00 token
    .setInitialSupply(100_000)         // 1 000.00 DEMO in treasury
    .setSupplyType(TokenSupplyType.Infinite)            // cap equals initial supply
    .setTreasuryAccountId(operatorId)
    .setAdminKey(adminKey.publicKey)   
    .setSupplyKey(supplyKey.publicKey) 
    .setTokenMemo("Created for Pick-n-get Reward system")
    .freezeWith(client);

    // Sign with the admin key, execute with the operator, and get receipt
    const signedTx = await transaction.sign(adminKey);
    const txResponse = await signedTx.execute(client);
    const receipt = await txResponse.getReceipt(client);
    const tokenId = receipt.tokenId;

    console.log(`\nFungible token created: ${tokenId.toString()}`)

    console.log("\nWaiting for Mirror Node to update...");
    await new Promise(resolve => setTimeout(resolve, 3000));

    const mirrorNodeUrl = `https://testnet.mirrornode.hedera.com/api/v1/accounts/${operatorId}/tokens?token.id=${tokenId}`;

    const response = await fetch(mirrorNodeUrl);
    const data = await response.json();
    
    if (data.tokens && data.tokens.length > 0) {
        const balance = data.tokens[0].balance;
        console.log(`\nTreasury holds: ${balance} \n`);
    } else {
        console.log("Token balance not yet available in Mirror Node");
    }

    client.close();
}

createToken().catch(console.error);


// Fungible token created: 0.0.6887758
//token id = 0.0.6887758

// Waiting for Mirror Node to update...

// Treasury holds: 100000 