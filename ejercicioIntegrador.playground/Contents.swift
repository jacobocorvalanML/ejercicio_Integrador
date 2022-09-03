//: A UIKit based Playground for presenting user interface
  
import Foundation

protocol Parkable: Hashable {
    var plate: String { get }
    var type: VehicleType { get }
    var discountCard: String? { get }
    var hasDiscountCard: Bool { get }
    var checkInTime: Date { get }
    var parkedTime: Int { get }
}

extension Parkable {
    var hasDiscountCard: Bool { discountCard != nil }
}

extension Parkable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(plate)
    }
}

struct Parking {
    
    var vehicles: Set<Vehicle>
    let maxVehicles = 20
    var register: (vehicle: Int, fee: Int) = (vehicle: 0, fee: 0)
    
    mutating func checkInVehicle(_ vehicle: Vehicle, onFinish:(Bool) -> Void) {
        
        guard !vehicles.contains(vehicle) && maxVehicles > self.vehicles.count else {
            
            return onFinish(false)
        }
        
        self.vehicles.insert(vehicle)
        
        return onFinish(true)
    }
    
    mutating func checkOutVehicle(plate:String, onSucces: (Int)->Void, onError: () -> Void) {
        
        guard let vehicle = vehicles.first(where: {$0.plate == plate}) else{
            onError()
            return
        }
        
        let hasDiscound = vehicle.discountCard != nil
        let value = calculateFee(type: vehicle.type, hasDiscountCard: hasDiscound, parkedTime: vehicle.parkedTime)
        
        
        vehicles.remove(vehicle)
        
        register.vehicle += 1
        register.fee += value
        
        onSucces(value)
    }
    
    func calculateFee(type: VehicleType,hasDiscountCard:Bool, parkedTime: Int) -> Int{
       let timeInitial = 120
        var buy = 0
        let excedenteSinDescuento = (Int(ceil(Double(parkedTime - timeInitial) / 15)) * 5)
    
        if parkedTime <= timeInitial {
            if hasDiscountCard{
                buy = Int(floor(Double(type.rate) / 1.15))
                return buy
            }else{
                buy = type.rate
                return buy
            }
        }
        else if hasDiscountCard {
            buy = (Int(floor(Double(excedenteSinDescuento) + Double(type.rate) ) * 0.85))
            return buy
        }
        buy = excedenteSinDescuento + type.rate
        return buy
   }
    
    func reportParking(){
        print("\(register.vehicle) vehicles have checked out and have earnings of \(register.fee)")
    }
    
    func listOfPlates() {
            vehicles.map { vehicles in
                print(vehicles.plate)
            }
        }
}

struct Vehicle: Parkable {
    let plate: String
    let type: VehicleType
    let checkInTime: Date
    var discountCard: String?
    var parkedTime: Int {
        Calendar.current.dateComponents([.minute], from: checkInTime, to: Date()).minute ?? 0
    }
    
    static func ==(lhs: Vehicle, rhs: Vehicle) -> Bool {
        lhs.plate == rhs.plate
    }
}

enum VehicleType {
    case car
    case miniBus
    case bus
    case moto
    
    var rate: Int {
        switch self {
        case .car: return 20
        case .moto: return 15
        case .miniBus: return 25
        case .bus: return 30
        }
    }
}

var arrayVehicles = [
    Vehicle(plate: "AA111AA", type:VehicleType.car, checkInTime: Date(), discountCard:"DISCOUNT_CARD_001"),
    Vehicle(plate: "AA111JA", type:VehicleType.moto, checkInTime: Date(), discountCard: nil),
    Vehicle(plate: "CC333CC", type:VehicleType.miniBus, checkInTime: Date(), discountCard:nil),
    Vehicle(plate: "DD444DD", type:VehicleType.bus, checkInTime: Date(), discountCard:"DISCOUNT_CARD_002"),
    Vehicle(plate: "AA111BB", type:VehicleType.car, checkInTime: Date(), discountCard:"DISCOUNT_CARD_003"),
    Vehicle(plate: "B222CCC", type:VehicleType.moto, checkInTime: Date(), discountCard:"DISCOUNT_CARD_004"),
    Vehicle(plate: "CC333DD", type:VehicleType.miniBus, checkInTime: Date(), discountCard:nil),
    Vehicle(plate: "DD444EE", type:VehicleType.bus, checkInTime: Date(), discountCard:"DISCOUNT_CARD_005"),
    Vehicle(plate: "AA111CC", type:VehicleType.car, checkInTime: Date(), discountCard: nil),
    Vehicle(plate: "B222DDD", type:VehicleType.moto, checkInTime: Date(), discountCard: nil),
    Vehicle(plate: "CC333EE", type:VehicleType.miniBus, checkInTime: Date(), discountCard:nil),
    Vehicle(plate: "DD444GG", type:VehicleType.bus, checkInTime: Date(), discountCard:"DISCOUNT_CARD_006"),
    Vehicle(plate: "AA111DD", type:VehicleType.car, checkInTime: Date(), discountCard:"DISCOUNT_CARD_007"),
    Vehicle(plate: "B222EEE", type:VehicleType.moto, checkInTime: Date(), discountCard: nil),
    Vehicle(plate: "CC331FF", type:VehicleType.miniBus, checkInTime: Date(), discountCard:nil),
    Vehicle(plate: "CT333FF", type:VehicleType.miniBus, checkInTime: Date(), discountCard:nil),
    Vehicle(plate: "CC333FF", type:VehicleType.miniBus, checkInTime: Date(), discountCard:nil),
    Vehicle(plate: "CC331YF", type:VehicleType.miniBus, checkInTime: Date(), discountCard:nil),
    Vehicle(plate: "LC333FF", type:VehicleType.miniBus, checkInTime: Date(), discountCard:nil),
    Vehicle(plate: "CC383FF", type:VehicleType.miniBus, checkInTime: Date(), discountCard:nil),
    Vehicle(plate: "ZC733FZZ", type:VehicleType.miniBus, checkInTime: Date(), discountCard:nil)
]

let vehiculo1 = Vehicle(plate: "ZC733FZZ", type:VehicleType.car, checkInTime: Date(), discountCard:nil)

var alkeParking = Parking(vehicles:[])

//Check de ingreso
print("//////////// income check //////////////")
arrayVehicles.forEach { vehicle in
    alkeParking.checkInVehicle(vehicle) { verification in
        verification ? print("Welcome to AlkeParking! place -> \(arrayVehicles.index(of: vehicle)!)") : print("Sorry, the check-in failed")
    }
}

print("")
//Retiro de vehiculos y pagos
print("//////////// BUY ///////////////")
alkeParking.checkOutVehicle(plate: "AA111DD") { value in
    print("Your fee is $\(value). Come back soon")
} onError: {
    print("Sorry, the check-out failed")
}

alkeParking.checkOutVehicle(plate: "AA111JA") { value in
    print("Your fee is $\(value). Come back soon")
} onError: {
    print("Sorry, the check-out failed")
}

print(" ")
// lista de de patentes
print("//////////// PLATE LIST ///////////////")
alkeParking.listOfPlates()

print("")
//reporte de vahículos retirados y ganancias
alkeParking.reportParking()

