// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract Product {
    uint256[] public productIds;
    uint256 public productCount;
    uint256 private registrationCount;

    enum ProductStatus {Available, NotAvailable}

    struct Details {
        string name;
        string country;
        uint256 phoneNumber;
    }

    struct Products {
        uint256 productId;
        string name;
        uint256 quantity;
        address owner;
        string description;
        bytes data;
        uint256 amount;
        ProductStatus productStatus;
    }

    //registration id 
    mapping(uint256 => bool) public isProducerRegistered;
    //registration id per details 
    mapping (uint256 => Details) public ownerDetails;
    // check if its the owner of the product by id
    mapping (uint256 => address) public productOwner;
    //registration Id
    mapping (address => uint256) public registrationId;
    //registration Address
    mapping (uint256 => address) public registrationAddress;
    mapping (uint256 => mapping(uint256 => Products)) public  allProductsByProducer;
    //used for looking up a producer by his id;
    mapping (uint256 => uint256) public productIdByOwner;
    //producer id to number of product they have used for giving givingg id to a specific producer
    mapping (uint256 => uint256) public productCountByOwner;
    mapping (uint256 => bool) public validPid;
    mapping (uint256 => uint256[]) public productsByProducerId;
    mapping (uint256 => Products) public products;
    mapping (address => mapping(uint256 => bool)) public isProducerPaidForProduct;
    


    event ProductAdded(uint256 indexed id, address owner);

    error AlreadyRegistered();
    error Invalid(address);
    error ProductSoldOut();
    error InsufficientStock();

    function registerProductOwner (address _producer, string memory  _name, string memory _country, uint256 _number) internal {
        if(_producer == address(0)){
            revert Invalid(_producer);
        }
        if(registrationId[_producer] != 0){
            revert AlreadyRegistered();
        }

        registrationCount++;
        ownerDetails[registrationCount] = Details({
            name : _name,
            country : _country,
            phoneNumber : _number
        });

        isProducerRegistered[registrationCount] = true;
        registrationId[_producer] = registrationCount;
        registrationAddress[registrationCount] = _producer; 
    }
   

    function getProductOwner(uint256 _id) internal view returns (address) {
        require(isProducerRegistered[_id], "Product not registered");
        return productOwner[_id];
    }

    function _addProducts(uint256 _id, string memory _name, uint256 _quantity, string memory _description, bytes memory _data, uint256 _amount, uint8 _decimals) public {
          if(isProducerRegistered[_id] == false){
            revert ("Not Authorized");
        }
    
        address _owner = registrationAddress[_id];

        productOwner[_id] = _owner;

        productCount++;

        productCountByOwner[_id]++;
        
        allProductsByProducer[_id][productCountByOwner[_id]] = Products({
            productId : productCountByOwner[_id],
            name : _name,
            quantity : _quantity,
            owner : _owner,
            description : _description,
            data : _data,
            amount : _amount * (10**_decimals),
            productStatus : ProductStatus.Available
        });

        productIds.push(productCountByOwner[_id]);
        productIdByOwner[productCountByOwner[_id]] = _id;
        productsByProducerId[_id] = productIds; 
        validPid[productCountByOwner[_id]] = true;  
        products[productCountByOwner[_id]] = Products({
            productId : productCountByOwner[_id],
            name : _name,
            quantity : _quantity,
            owner : _owner,
            description : _description,
            data : _data,
            amount : _amount * (10**_decimals),
            productStatus : ProductStatus.Available
        });
    }

    function _shopProduct(uint256 _pid, uint256 _quantity) internal  {
          require(_pid > 0, "Invalid product ID");
        require(validPid[_pid] == true, "No product with that id" );
        uint256 _owner = productIdByOwner[_pid];
        address _producer = productOwner[_owner];
        Products storage product = allProductsByProducer[_owner][_pid]; 

        if(product.productStatus == ProductStatus.NotAvailable){
            revert ProductSoldOut();
        }

        if (product.quantity < _quantity) {
            revert InsufficientStock();
        }

        uint256 totalCost = _quantity * product.amount ;
        require(msg.value == totalCost, "Incorrect payment");

        productCount--;
        productCountByOwner[_owner]--;
        for(uint256 i = 0; i < productIds.length; i++){
            if(productIds[i] == _pid){
                productIds[i] = productIds[productIds.length - 1];
                productIds.pop();
                break;
            }
        }

        product.quantity -= _quantity;
        if (product.quantity == 0) {
            product.productStatus = ProductStatus.NotAvailable;
        }

        uint256[] storage activeProduct = productsByProducerId[_owner];
        for(uint256 i = 0; i < activeProduct.length; i++){
            if(activeProduct[i] == _pid){
                activeProduct[i] = activeProduct[activeProduct.length - 1];
                activeProduct.pop();
                break;
            }
        }
        require(isProducerPaidForProduct[_producer][_pid] == false, "Already paid producer ");
        payable(_producer).transfer(msg.value);
        isProducerPaidForProduct[_producer][_pid] = true;
    }
}
