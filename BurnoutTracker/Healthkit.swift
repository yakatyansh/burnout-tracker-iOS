import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager() // Singleton for easy access
    let healthStore = HKHealthStore()

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }

        let healthDataToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]

        let healthDataToWrite: Set<HKSampleType> = []


        healthStore.requestAuthorization(toShare: healthDataToWrite, read: healthDataToRead) { success, error in
            completion(success, error)
        }
    }
}
