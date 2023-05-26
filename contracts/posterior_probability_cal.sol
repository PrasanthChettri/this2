// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./trust_calculation.sol";
import "./trust_store.sol";
import "./RSU.sol";

contract PosteriorProbabilityCalculator {
    CredibilityMetrics public cm;
    RSU public rsu;
    uint public P_e;
    uint[] credibility = [0];
    uint[] credibilitySourceIds = [0];
    mapping(string => uint) peMapping;


    function newEvent(string memory eventType, string memory location, address add) public {
        P_e = peMapping[eventType] != 0 ? peMapping[eventType] : 500;
        cm = new CredibilityMetrics(eventType, location);
        cm.setSourceTrust(add);
        credibilitySourceIds  =[0];
        rsu = cm.getRsu();
        credibility = [0] ;
    }

    function callEventCredibility(uint sourceId, uint distance) public {
        cm.setEvent(sourceId, distance);
        credibility.push(cm.getEventCredibility());
        credibilitySourceIds.push(sourceId);
    }

    function getUpdatedSourceTrust() public view returns (uint[] memory) {
        uint256[] memory trust_array = new uint256[](credibilitySourceIds.length );
        for (uint i = 1; i < credibilitySourceIds.length; i++) {
            trust_array[i] = cm.getTrust(credibilitySourceIds[i]);
        }
        return trust_array;
    }

    function calculatePosteriorProbability() public view returns (uint) {
        uint numerator = 0;
        uint denominator = 0;
        for (uint i = 1; i < credibility.length; i++) {
            numerator += P_e * credibility[i];
            denominator += numerator + (1000 - P_e) * (1000 - credibility[i]);
        }
        return  numerator * 1000 / denominator;
    }

    function updateVehicleTrust(bool offset) public {
        for (uint i = 1; i < credibilitySourceIds.length; i++) {
            rsu.updateVehicleTrust(credibilitySourceIds[i], cm.getTrust(credibilitySourceIds[i]), offset);
        }
    }
}
