// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
import "./trust_store.sol";

contract RSU {
    SourceTrust public sourceTrust;

    constructor() {
        sourceTrust = new SourceTrust();
        //sourceTrust.setSampleVehicles();
    }
    function setSourceTrust(address add) public{
        sourceTrust = SourceTrust(add) ;
    }

    function random(uint number) public view returns(uint){
        return 1 + uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % number;
    }
    function getRsuMessage(uint uuId) public view returns (uint, uint, string memory) {
        uint256 trust = sourceTrust.getSourceTrust(uuId);
        return (trust , 10, trust != 0  ? "legitimate" : "revoked");
    }
    function updateVehicleTrust(uint256 uuId, uint256 trust, bool offset) public {
        sourceTrust.updateSourceTrust(uuId, updateTrust(trust, offset));
    }
    function updateTrust(uint trust , bool offset) internal pure returns (uint256){
        if(trust < 3 && offset){
            return trust+3 ; 
        }
        else if(trust < 3 && !offset){
            return trust-1 < 0 ? 0 : trust - 1; 
        }
        else if(trust < 8 && offset) {
            return trust + 2 ; 
        }
        else if(trust < 8 && !offset) {
            return trust - 2 ;
        }
        else if(offset){
            return trust + 1 > 10 ? 10 : trust + 1; 
        }
        else {
            return trust - 3; 
        }
    }
}