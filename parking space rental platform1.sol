// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract ParkingRentalPlatform {
 // Define a structure for a parking space
 struct ParkingSpace {
 uint id;
 address owner;
 string location;
 uint pricePerHour; // Price per hour in wei
 bool isAvailable;
 }
 // Define a structure for a rental agreement
 struct RentalAgreement {
 uint spaceId;
 address renter;
 uint startTime;
 uint endTime;
 uint totalPrice;
 }
// State variables
 uint public nextSpaceId;
 uint public nextRentalId;
 mapping(uint => ParkingSpace) public parkingSpaces;
 mapping(uint => RentalAgreement) public rentalAgreements;
 mapping(address => uint[]) public userSpaces; // Spaces listed by users
 mapping(address => uint[]) public userRentals; // Rentals initiated by users
 // Events
 event ParkingSpaceListed(uint spaceId, address indexed owner, string location, uint 
pricePerHour);
 event ParkingSpaceRented(uint rentalId, uint spaceId, address indexed renter, uint 
startTime, uint endTime, uint totalPrice);
 event RentalEnded(uint rentalId, address indexed renter);
 // Modifier to check if the caller is the owner of a parking space
 modifier onlySpaceOwner(uint _spaceId) {
 require(parkingSpaces[_spaceId].owner == msg.sender, "Not the owner");
 _;
 }
 // Modifier to check if the space is available
 modifier spaceAvailable(uint _spaceId) {
 require(parkingSpaces[_spaceId].isAvailable, "Parking space not available");
 _;}
 // Function to list a new parking space
 function addParkingSpace(string memory _location, uint _pricePerHour) public {
 parkingSpaces[nextSpaceId] = ParkingSpace({
 id: nextSpaceId,
 owner: msg.sender,
 location: _location,
 pricePerHour: _pricePerHour,
 isAvailable: true
 });
 userSpaces[msg.sender].push(nextSpaceId);
 emit ParkingSpaceListed(nextSpaceId, msg.sender, _location, _pricePerHour);
 nextSpaceId++;
 }
 // Function to rent a parking space
 function rentParkingSpace(uint _spaceId, uint _startTime, uint _endTime) public payable 
spaceAvailable(_spaceId) {
 require(_startTime < _endTime, "Invalid rental time");
 require(block.timestamp <= _startTime, "Rental start time must be in the future");
 uint duration = (_endTime - _startTime) / 1 hours; // Duration in hours
 uint totalPrice = duration * parkingSpaces[_spaceId].pricePerHour;
 require(msg.value >= totalPrice, "Insufficient payment");
  // Create rental agreement
 rentalAgreements[nextRentalId] = RentalAgreement({
 spaceId: _spaceId,
 renter: msg.sender,
 startTime: _startTime,
 endTime: _endTime,
 totalPrice: totalPrice
 });
 // Mark the space as unavailable
 parkingSpaces[_spaceId].isAvailable = false;
 userRentals[msg.sender].push(nextRentalId);
 // Transfer payment to the space owner
 payable(parkingSpaces[_spaceId].owner).transfer(totalPrice);
 emit ParkingSpaceRented(nextRentalId, _spaceId, msg.sender, _startTime, _endTime, 
totalPrice);
 nextRentalId++;
 }
 // Function to end a rental
 function endRental(uint _rentalId) public {
 RentalAgreement storage rental = rentalAgreements[_rentalId];
 require(rental.renter == msg.sender, "Not the renter");
 require(block.timestamp >= rental.endTime, "Rental period has not ended");
 // Mark the space as available
 parkingSpaces[rental.spaceId].isAvailable = true;
 emit RentalEnded(_rentalId, msg.sender);
 // Remove rental agreement (optional, or handle it as needed)
 delete rentalAgreements[_rentalId];
 }
 // Function to get details of a parking space
 function getParkingSpace(uint _spaceId) public view returns (address, string memory, 
uint, bool) {
 ParkingSpace memory space = parkingSpaces[_spaceId];
 return (space.owner, space.location, space.pricePerHour, space.isAvailable);
 }
 // Function to get rental details
 function getRentalAgreement(uint _rentalId) public view returns (uint, address, uint, uint, 
uint) {
 RentalAgreement memory rental = rentalAgreements[_rentalId];
 return (rental.spaceId, rental.renter, rental.startTime, rental.endTime, 
rental.totalPrice);
 }
 // Function to get all spaces listed by a user
 function getUserSpaces() public view returns (uint[] memory) {
 return userSpaces[msg.sender];
  }
 // Function to get all rentals initiated by a user
 function getUserRentals() public view returns (uint[] memory) {
 return userRentals[msg.sender];
 }
}