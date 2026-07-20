# Changelog

All notable changes to this project will be documented in this file.

---

# v0.1.0

## Sprint 1 - Project Foundation

### Added

- Flutter project initialized
- Material 3 theme
- Initial project architecture
- Dashboard page
- Git repository initialized

---

# v0.2.0

## Sprint 3 - Engineering Analysis Engine

### Added

- Aircraft model
- Environment model
- AnalysisResult model
- AnalysisService
- AirDensityService
- LiftService
- DragService
- StallSpeedService
- FlightTimeService
- RiskService
- Engineering analysis form
- Analysis result page

---

# v0.3.0

## Sprint 4 - Professional Engineering UI & Battery Validation

### Added

- Reusable AnalysisSection widget
- BatteryValidationService
- Battery type selection (LiPo, Li-Ion, LiHV)
- Battery cell count support
- Battery voltage validation
- README_TR.md
- ROADMAP.md
- CHANGELOG.md

### Improved

- Professional analysis form layout
- Form validation
- Battery input workflow
- Project documentation

---

# v0.4.0

## Sprint 5 - Aircraft Performance Analysis

### Added

- AspectRatioService
- WingLoadingService
- PowerToWeightService
- ThrustService
- ResultCard widget
- ResultSection widget

### Added Engineering Metrics

- Aspect Ratio
- Wing Loading
- Power-to-Weight Ratio
- Estimated Thrust
- Thrust-to-Weight Ratio
- Wing Loading Status
- Power Status
- Thrust Status

### Improved

- AnalysisService
- AnalysisResult model
- Professional engineering result interface

---

# v0.5.0

## Sprint 6 - Engineering Recommendation & Performance Scoring

### Added

- RecommendationService
- ScoreService

### Added Performance Scoring

- Overall Engineering Score
- Aerodynamic Score
- Propulsion Score
- Energy Score

### Added Recommendation Engine

- Automatic engineering recommendations
- Aircraft performance evaluation
- Flight safety recommendations

### Improved

- Result page layout
- Engineering score panel
- Colored performance score cards
- Colored engineering status cards
- Professional engineering report interface

---

# v0.6.0-alpha

## Sprint 7A - Professional Dashboard UX

### Added

- Engineering Dashboard Hero Panel
- Dashboard statistics cards
- Dashboard footer
- Application version information
- Professional desktop dashboard layout
- Dashboard opening animation
- Hover animation for dashboard cards

### Improved

- Dashboard architecture
- Desktop user experience
- Dashboard card design
- Engineering visual identity
- Overall application appearance

---

# v0.7.0-alpha

## Sprint 7B - Aircraft Hangar

### Added

- Aircraft Hangar module
- Aircraft library page
- Aircraft search
- Aircraft filtering
- Aircraft duplication
- Aircraft deletion
- Aircraft edit infrastructure
- Turkish localization
- Persistent aircraft management workflow

### Improved

- Dashboard navigation
- Hangar user experience
- Aircraft management interface

---

# v0.8.0-beta

## Sprint 8 - Local Data Layer

### Added

- Hive CE integration
- AircraftEntity
- AircraftRepository
- AircraftMapper
- Local persistent storage
- Data layer architecture
- Repository pattern implementation

### Improved

- Project architecture
- Aircraft save/load workflow
- Data persistence reliability

---

# v0.9.0-beta

## Sprint 9A - International Standard Atmosphere (ISA)

### Added

- ISA atmospheric pressure model
- Altitude based pressure calculation
- Improved air density model
- Engineering atmosphere corrections

### Improved

- AirDensityService
- Environmental calculations
- Analysis accuracy

---

## Sprint 9B - Propulsion System

### Added

- MotorEfficiencyService
- Physics-based thrust calculation
- Motor efficiency model

### Improved

- ThrustService
- AnalysisService
- Propulsion accuracy
- Thrust-to-weight calculation

---

## Sprint 9C - Aircraft Type Aware Analysis

### Added

- Fixed Wing / Drone differentiation
- Conditional aerodynamic analysis
- Conditional stall calculations
- Conditional wing loading calculations
- Vehicle-aware recommendation system

### Improved

- RecommendationService
- ScoreService
- RiskService
- AnalysisResult
- Professional engineering scoring

---

## Sprint 9D - Advanced Battery Model

### Added

- Battery reserve model
- Usable battery capacity calculation
- Battery health factor infrastructure
- Temperature correction factor infrastructure
- Load correction factor infrastructure
- FlightTimeResult model
- Detailed flight time calculation

### Improved

- FlightTimeService
- Flight endurance estimation
- Input validation
- Energy calculation accuracy

---

---

# v1.0.0-beta

---

## Sprint 10A - Vehicle Specific Mission Power Engine

### Added

- MissionPowerService
- MissionPowerResult model
- Multirotor hover mission power model
- Fixed-wing cruise mission power model
- VTOL hybrid mission power model
- Average mission power calculation
- Peak mission power calculation
- Installed power reserve calculation
- Installed power reserve percentage
- Peak power usage ratio
- Motor system sufficiency evaluation
- Average battery current reporting
- Nominal battery energy calculation
- Usable battery energy calculation

### Improved

- FlightTimeService
- AnalysisService
- Vehicle-type-aware power calculations
- Flight endurance estimation accuracy
- Energy analysis transparency
- Energy & Endurance report section
- Power Reserve report section

---

## Sprint 10B - Realistic Aerodynamic Performance Engine

### Added

- AerodynamicPerformanceService
- AerodynamicPerformanceResult model
- Vehicle-specific cruise speed model
- Required cruise lift coefficient calculation
- Zero-lift drag coefficient (CD0)
- Parabolic drag polar model
- Oswald efficiency factor
- Induced drag factor calculation
- Dynamic pressure calculation
- Lift-to-drag ratio calculation
- CL / CLmax usage ratio calculation
- Cruise aerodynamic validity evaluation
- Persistent aerodynamic aircraft parameters
- Cruise speed storage
- CD0 storage
- CLmax storage
- Oswald efficiency storage

### Improved

- Lift force calculation accuracy
- Drag force calculation accuracy
- Fixed-wing cruise performance analysis
- VTOL wing-borne cruise calculations
- Mission power calculations
- AnalysisService
- Aircraft model
- AircraftEntity
- AircraftMapper
- Professional aerodynamic report interface

---

## Sprint 11 - Professional Propulsion System Analysis Engine

### Added

- PropulsionPowerChainService
- PropulsionLoadService
- PropulsionSystemService
- ESC efficiency model
- Motor efficiency model improvements
- Continuous motor power model
- Maximum motor power model
- ESC output power calculation
- Motor shaft power calculation
- Useful propulsive power calculation
- Total propulsion efficiency calculation
- Average continuous motor load ratio calculation
- Peak maximum motor load ratio calculation
- Continuous power reserve calculation
- Maximum power reserve calculation
- Propulsion system status evaluation
- Persistent propulsion aircraft parameters
- ESC efficiency storage
- Motor efficiency storage
- Continuous motor power storage
- Maximum motor power storage
- Propulsion power chain result reporting
- Motor load analysis result reporting

### Improved

- AnalysisService
- AnalysisResult model
- Aircraft model
- AircraftEntity
- AircraftMapper
- Aircraft creation and edit workflow
- Engineering analysis form
- Mission power integration
- Flight time estimation accuracy
- Battery current estimation accuracy
- Propulsion system analysis accuracy
- Professional propulsion report interface

---

---

## Sprint 12 - Professional Battery System Analysis Engine

### Added

- BatteryChemistryService
- BatteryElectricalService
- BatteryDischargeCurveService
- BatterySystemService
- BatteryScoreService
- BatteryRecommendationService
- Battery chemistry model
- Cell and pack voltage model
- Full pack voltage calculation
- Nominal pack voltage calculation
- Minimum safe pack voltage calculation
- Cell internal resistance model
- Pack internal resistance calculation
- Average voltage sag calculation
- Peak voltage sag calculation
- Average loaded voltage calculation
- Peak loaded voltage calculation
- Average battery current calculation
- Peak battery current calculation
- Average C-rate calculation
- Peak C-rate calculation
- Battery load efficiency calculation
- Real usable battery energy calculation
- Real flight time calculation
- Battery system safety evaluation
- Battery score calculation
- Battery safety recommendation engine
- Persistent battery internal resistance parameter
- Professional battery result reporting

### Improved

- AnalysisService
- AnalysisResult model
- Aircraft model
- AircraftEntity
- AircraftMapper
- Aircraft creation and edit workflow
- Battery validation
- Flight time estimation accuracy
- Battery current estimation accuracy
- Battery safety analysis
- Battery recommendation reporting
- Energy and battery result interface

---

## Sprint 13 - Atmosphere & Wind System

### Added

- AtmosphereSystemResult model
- AtmosphereSystemService
- WindSystemResult model
- WindSystemService
- Moist air density calculation
- Saturation vapor pressure calculation
- Water vapor partial pressure calculation
- Dry air partial pressure calculation
- ISA temperature comparison
- ISA pressure comparison
- ISA density comparison
- Temperature deviation calculation
- Pressure deviation calculation
- Density deviation calculation
- Density altitude calculation
- Density altitude difference calculation
- Atmosphere status evaluation
- Atmosphere supported-limits validation
- Wind speed conversion from km/h to m/s
- Headwind component calculation
- Tailwind component calculation
- Crosswind component calculation
- Crosswind direction reporting
- Effective airspeed calculation
- Estimated ground speed calculation
- Wind intensity classification
- Wind safety evaluation
- Wind supported-limits validation
- Professional Atmosphere Analysis report section
- Professional Wind System Analysis report section
- Atmosphere and wind recommendation integration
- Atmosphere and wind aerodynamic score integration
- Atmosphere service unit tests
- Wind service unit tests
- Atmosphere integration tests
- Wind integration tests

### Improved

- AnalysisService
- AnalysisResult model
- RecommendationService
- ScoreService
- Aerodynamic density integration
- Thrust density integration
- Mission power atmosphere integration
- Vehicle-type-aware wind analysis
- Engineering recommendation accuracy
- Engineering score realism
- Worst-case atmosphere evaluation
- Wind risk reporting
- Professional engineering result interface
- Density altitude display formatting

### Validated

- Normal sea-level atmosphere test
- High-altitude and high-temperature atmosphere test
- Maximum humidity atmosphere test
- Calm wind test
- Headwind test
- Tailwind test
- Left crosswind test
- Right crosswind test
- Worst-case atmosphere test
- Atmosphere recommendation test
- Wind recommendation test
- Atmosphere score penalty test
- Wind score penalty test
- Fixed-wing real vehicle test
- Flutter static analysis
- Automated test suite


---

## Sprint 14 - Component Database & Real Motor-Propeller Validation

### Added

- MotorComponent model
- PropellerComponent model
- BatteryComponent model
- EscComponent model
- MotorPropellerCombination model
- MotorPropellerPerformancePoint model
- ComponentCompatibilityResult model
- CompatibilityIssue model
- CompatibilitySeverity classification
- Component repository architecture
- MotorRepository
- PropellerRepository
- BatteryComponentRepository
- EscRepository
- MotorPropellerCombinationRepository
- Real motor-propeller performance data catalog
- T-MOTOR MN501-S KV240 + P14x4.8 performance table
- T-MOTOR MN3510 KV360 + P15x5 CF performance table
- T-MOTOR MN4014 KV400 + P15x5 CF performance table
- Motor-propeller data catalog lookup
- Persistent motor component identifier
- Persistent propeller component identifier
- Persistent battery component identifier
- Persistent ESC component identifier
- Persistent motor-propeller combination identifier
- Hangar motor-propeller data source selector
- Manual component input mode
- Real test table selection mode
- Component selection persistence
- ComponentCompatibilityService
- Motor-battery voltage compatibility validation
- Motor-battery cell count compatibility validation
- Battery continuous current validation
- Battery burst current validation
- Motor-propeller diameter compatibility validation
- Propeller-motor KV compatibility validation
- Propeller-battery voltage compatibility validation
- ESC cell count compatibility validation
- ESC continuous current validation
- ESC burst current validation
- ESC current reserve validation
- Motor-propeller test table identifier validation
- Test table voltage validation
- Component compatibility score
- Component compatibility status
- Component compatibility message
- Real maximum thrust per motor reporting
- Real total maximum thrust reporting
- Real maximum current per motor reporting
- Real total maximum current reporting
- Real maximum power per motor reporting
- Real total maximum power reporting
- Real test voltage reporting
- Real thrust-to-weight calculation
- Component Validation result section
- Test data source reporting
- Test conditions reporting
- Selected component identifier reporting
- Manual component validation information card
- Real test table compatibility information card
- Critical component mismatch reporting

### Improved

- Aircraft model
- AircraftEntity
- Hive aircraft adapter
- AircraftMapper
- Aircraft creation and edit workflow
- Aircraft Hangar form
- New Analysis workflow
- AnalysisService
- AnalysisResult model
- Analysis result interface
- Motor-propeller engineering transparency
- Real thrust reporting accuracy
- Component selection traceability
- Manual input backward compatibility
- Hangar-to-analysis component data transfer
- Engineering validation reporting

### Validated

- Component model serialization
- Component repository lookup
- Real motor-propeller catalog integrity
- Thirty real performance data points
- Aircraft component identifier persistence
- Aircraft mapper component round-trip
- Legacy aircraft manual-mode compatibility
- Compatible motor-propeller selection
- Missing real test table scenario
- Motor-battery incompatibility scenario
- Motor-propeller diameter incompatibility scenario
- Motor-propeller KV incompatibility scenario
- ESC current insufficiency scenario
- Low ESC current reserve warning
- Test table component identifier mismatch
- Test table voltage mismatch
- Manual analysis flow
- Real test table AnalysisResult integration
- Multi-motor thrust, current and power scaling
- Missing catalog combination handling
- Hangar component selection restoration
- Hangar-to-analysis component identifier transfer
- Compatible real application test
- Incompatible propeller diameter application test
- Manual component input application test
- Flutter static analysis
- Automated test suite


---

---

## Current Engineering Capabilities

### Aerodynamics

- ISA Atmosphere Model
- Air Density
- Lift Force
- Drag Force
- Stall Speed
- Aspect Ratio
- Wing Loading
- Vehicle-Specific Cruise Speed
- Required Cruise Lift Coefficient
- Zero-Lift Drag Coefficient
- Parabolic Drag Polar
- Oswald Efficiency Factor
- Induced Drag Factor
- Dynamic Pressure
- Lift-to-Drag Ratio
- CL / CLmax Usage Ratio
- Cruise Aerodynamic Validity Evaluation

### Propulsion

- Physics-Based Thrust Estimation
- Motor Efficiency
- ESC Efficiency Model
- Continuous Motor Power Model
- Maximum Motor Power Model
- Power-to-Weight Ratio
- Thrust-to-Weight Ratio
- Drone Hover Power Model
- Fixed-Wing Cruise Power Model
- VTOL Hybrid Mission Power Model
- Average Mission Power
- Peak Mission Power
- Installed Power Reserve
- Peak Power Usage Ratio
- Motor System Sufficiency Evaluation
- Propulsion Power Chain Analysis
- ESC Output Power Calculation
- Motor Shaft Power Calculation
- Useful Propulsive Power Calculation
- Total Propulsion Efficiency Calculation
- Motor Load Analysis
- Average Continuous Motor Load Ratio
- Peak Maximum Motor Load Ratio
- Continuous Power Reserve Evaluation
- Maximum Power Reserve Evaluation
- Propulsion System Status Evaluation

### Energy

- Battery Validation
- Battery Reserve Model
- Detailed Flight Time Estimation
- Nominal Battery Energy
- Usable Battery Energy
- Average Battery Current
- Battery Utilization Ratio
- Battery Health Infrastructure
- Temperature Correction Infrastructure
- Load Correction Infrastructure

### Performance Evaluation

- Overall Engineering Score
- Aerodynamic Score
- Propulsion Score
- Energy Score
- Risk Assessment
- Recommendation Engine
- Vehicle Type Aware Analysis
- Cruise Validity Evaluation
- Power Reserve Evaluation
- Propulsion System Evaluation

### Data Management

- Hive Database
- Aircraft Repository
- Aircraft Library
- Persistent Storage
- Persistent Aerodynamic Parameters
- Persistent Propulsion Parameters
- Cruise Speed Storage
- CD0 Storage
- CLmax Storage
- Oswald Efficiency Storage
- ESC Efficiency Storage
- Motor Efficiency Storage
- Continuous Motor Power Storage
- Maximum Motor Power Storage

### User Interface

- Professional Dashboard
- Aircraft Hangar
- Engineering Analysis Form
- Professional Result Report
- Advanced Aerodynamic Performance Section
- Mission Power Analysis Section
- Energy & Endurance Section
- Power Reserve Section
- Advanced Propulsion Analysis Section
- Vehicle-Type-Specific Result Display

# v0.15.0

## Sprint 15 - Advanced Flight Performance & Stability Analysis

### Added

- Climb performance result model and engineering service
- Available propulsive power calculation
- Required level-flight power calculation
- Excess power calculation
- Rate of climb calculation in m/s and ft/min
- Climb angle and time-to-altitude calculations
- Endurance and range result model and engineering service
- Usable battery energy based endurance calculation
- Still-air and wind-adjusted range calculations
- Ground speed calculation based on wind conditions
- Glide performance result model and engineering service
- Best glide ratio and best glide speed calculations
- Sink rate, glide angle, glide distance and glide time calculations
- Aircraft mass station model
- Component-based center of gravity calculation
- Mean aerodynamic chord based CG position calculation
- Neutral point and static margin calculations
- CG operating limit validation
- Longitudinal static stability evaluation
- Flight envelope result model and engineering service
- Minimum operating speed calculation
- Maneuvering speed calculation
- Maximum operating speed validation
- Positive and negative limit load factors
- Maximum dynamic pressure calculation
- Cruise flight envelope validation
- Flight performance fields in new analysis and aircraft hangar forms
- Hive persistence support for mass stations and flight envelope inputs
- Climb Performance result section
- Endurance & Range result section
- Glide Performance result section
- Center of Gravity & Stability result section
- Flight Envelope result section
- Unit tests for all Sprint 15 engineering services

### Improved

- Main analysis service now produces integrated advanced flight performance results
- Analysis result model now carries climb, endurance, glide, stability and flight envelope results
- Fixed-wing and winged VTOL applicability validation
- Result card responsive layout and overflow handling
- Engineering status colors and result explanations
- Hangar editing and analysis input persistence
- Windows desktop analysis workflow

### Validation

- Flutter analyzer completed with no issues
- 90 automated tests passed
- Windows release build completed successfully
- Real fixed-wing UI tests completed for climb, endurance, glide, stability and flight envelope

# v0.16.0

## Sprint 16 - Validation, Reliability & Release Readiness

### Added

- Boundary tests for core aerodynamic services
- Boundary tests for battery and energy services
- Boundary tests for propulsion services
- Boundary tests for advanced performance and stability services
- Vehicle-type applicability tests for the main analysis service
- Hangar persistence and data integrity tests
- Responsive UI and user flow tests
- Dashboard tests for 1280x800, 900x700 and 600x700 window sizes
- New analysis page rendering and scrolling tests
- Fixed-wing and drone result page responsive tests

### Improved

- Lift service input validation
- Drag service input validation
- Stall speed service input validation
- Aircraft entity unique ID generation
- Aircraft duplication ID safety
- Dashboard responsive layout
- Dashboard narrow-screen scrolling
- Dashboard header and card layout behavior
- Result section title overflow handling
- Engineering recommendation title overflow handling
- Fixed-wing and drone result display at narrow desktop sizes

### Fixed

- Duplicate aircraft ID collisions during rapid creation and duplication
- Invalid aerodynamic service inputs producing unsafe calculations
- Dashboard horizontal overflow at 600x700
- Dashboard vertical overflow at reduced window heights
- Result section horizontal overflow on narrow screens
- Engineering recommendation header overflow on narrow screens

### Validation

- Flutter analyzer completed with no issues
- 195 automated tests passed
- 10 responsive UI and user flow tests passed
- Windows release build completed successfully
- Real release-mode drone analysis completed successfully
- Real release-mode fixed-wing analysis completed successfully
- Aircraft library create, edit, duplicate and delete flows verified
- Aircraft persistence after application restart verified
- Release UI checked without visible overflow
