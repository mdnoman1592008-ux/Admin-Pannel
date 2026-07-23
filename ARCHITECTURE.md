# Ether Cinema Architectural Specification

## Clean Architecture Layers

1. **Presentation Layer (`lib/screens/`, `lib/widgets/`)**: VisionOS widgets, state management listeners, and screen views.
2. **Domain Layer (`lib/domain/`)**: UseCases, Entities, and Business Rule Validators.
3. **Data Layer (`lib/data/`, `lib/core/`)**: Repositories, Data Sources, Mappers, and Firebase/Dailymotion integrations.

## Role-Based Access Control (RBAC) Matrix

| Permission Gate | User | Moderator | Admin | Super Admin |
| :--- | :---: | :---: | :---: | :---: |
| **Stream Movies** | ✓ | ✓ | ✓ | ✓ |
| **Moderate Content Reports** | ✗ | ✓ | ✓ | ✓ |
| **Manage Movies & Banners** | ✗ | ✗ | ✓ | ✓ |
| **Manage Admins & Security** | ✗ | ✗ | ✗ | ✓ |
