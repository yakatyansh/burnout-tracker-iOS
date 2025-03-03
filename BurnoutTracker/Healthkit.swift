import HealthKit
import Combine

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()

    @Published var stepCount: Double = 0
    @Published var heartRate: Double = 0
    @Published var caloriesBurned: Double = 0

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let healthDataToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]

        healthStore.requestAuthorization(toShare: nil, read: healthDataToRead) { success, error in
            if success {
                self.startFetchingData()
            } else {
                print("❌ HealthKit Authorization Failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func startFetchingData() {
        fetchStepCount()
        fetchHeartRate()
        fetchCaloriesBurned()
    }

    // Fetch Step Count
    func fetchStepCount() {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            DispatchQueue.main.async {
                if let sum = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) {
                    self.stepCount = sum
                } else {
                    print("❌ Failed to fetch steps: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
        healthStore.execute(query)
    }

    // Fetch Heart Rate in real-time
    func fetchHeartRate() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }

        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] _, _, error in
            if let error = error {
                print("❌ Failed to fetch heart rate: \(error.localizedDescription)")
                return
            }
            self?.fetchLatestHeartRate()
        }
        healthStore.execute(query)
    }

    func fetchLatestHeartRate() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }

        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, results, error in
            DispatchQueue.main.async {
                if let sample = results?.first as? HKQuantitySample {
                    self.heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                } else {
                    print("❌ Failed to fetch latest heart rate: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
        healthStore.execute(query)
    }

    // Fetch Calories Burned
    func fetchCaloriesBurned() {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: calorieType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            DispatchQueue.main.async {
                if let sum = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) {
                    self.caloriesBurned = sum
                } else {
                    print("❌ Failed to fetch calories: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
        healthStore.execute(query)
    }
}
