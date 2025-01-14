pragma solidity 0.8.9;

import "../../../PaymentProcessorSaleScenarioBase.t.sol";

contract SingleSaleNoFeesColdPurchase is PaymentProcessorSaleScenarioBase {

    function setUp() public virtual override {
        super.setUp();

        erc1155Mock.mintTo(sellerEOA, _getNextAvailableTokenId(address(erc1155Mock)), 100);
        erc1155Mock.mintTo(sellerEOA, _getNextAvailableTokenId(address(erc1155Mock)), 100);
        erc1155Mock.mintTo(sellerEOA, _getNextAvailableTokenId(address(erc1155Mock)), 90);
    }

    function test_executeSale() public {
        MatchedOrder memory saleDetails = MatchedOrder({
            sellerAcceptedOffer: false,
collectionLevelOffer: false,
            protocol: TokenProtocols.ERC1155,
            paymentCoin: address(0),
            tokenAddress: address(erc1155Mock),
            seller: sellerEOA,
            privateBuyer: address(0),
            buyer: buyerEOA,
            delegatedPurchaser: address(0),
            marketplace: address(marketplaceMock),
            marketplaceFeeNumerator: 0,
            maxRoyaltyFeeNumerator: 0,
            listingNonce: _getNextNonce(sellerEOA),
            offerNonce: _getNextNonce(buyerEOA),
            listingMinPrice: 1 ether,
            offerPrice: 1 ether,
            listingExpiration: type(uint256).max,
            offerExpiration: type(uint256).max,
            tokenId: 2,
            amount: 10
        });

        _mintAndDealTokensForSale(saleDetails.protocol, address(0), saleDetails);

        _executeSingleSale(
            saleDetails.delegatedPurchaser != address(0) ? saleDetails.delegatedPurchaser : saleDetails.buyer, 
            saleDetails, 
            _getSignedListing(sellerKey, saleDetails), 
            _getSignedOffer(buyerKey, saleDetails),
            false);

        assertEq(erc1155Mock.balanceOf(sellerEOA, 0), 100);
        assertEq(erc1155Mock.balanceOf(sellerEOA, 1), 100);
        assertEq(erc1155Mock.balanceOf(sellerEOA, 2), 90);
        assertEq(erc1155Mock.balanceOf(buyerEOA, 0), 0);
        assertEq(erc1155Mock.balanceOf(buyerEOA, 1), 0);
        assertEq(erc1155Mock.balanceOf(buyerEOA, 2), 10);

        assertEq(sellerEOA.balance, 1 ether);
        assertEq(buyerEOA.balance, 0 ether);
        assertEq(address(marketplaceMock).balance, 0 ether);
        assertEq(address(royaltyReceiverMock).balance, 0 ether);
    }
}