# 🔍 **CODE REVIEW PROTOCOL - BUG DETECTION CHECKLIST (Go-Specific)**

> **For AI (Cursor)**: After completing ANY code implementation, refactoring, or optimization, you MUST perform this systematic review to catch bugs, inefficiencies, and logical errors specific to Go and this project's architecture.

## 🎯 **PRIMARY GOAL: Find Bugs Before They Cause Problems**

**Reward System**: Finding bugs early is VALUABLE. You're being THOROUGH and PROACTIVE, not nitpicky. Every bug caught here saves debugging time later.

---

## 📑 **TABLE OF CONTENTS**

### **Main Review Steps**
- [**STEP 1: Execution Flow Tracing**](#step-1-execution-flow-tracing--critical) (Line 77)
  - 1.1 Entry Point Analysis (Line 81)
  - 1.2 Data Flow Tracking (Line 96)
  - 1.3 Function Call Verification (Line 124)
  - 1.4 Control Flow Verification (Line 151)
- [**STEP 2: Resource Management Review**](#step-2-resource-management-review-) (Line 162)
  - 2.1 Memory Leaks (Line 166)
  - 2.2 Database/Connection Management (Line 188)
  - 2.3 Context Management (Line 212)
- [**STEP 3: Logic Verification**](#step-3-logic-verification-) (Line 232)
  - 3.1 Algorithm Correctness (Line 236)
  - 3.2 State Consistency (Line 257)
  - 3.3 Side Effects (Line 275)
- [**STEP 4: Performance Analysis**](#step-4-performance-analysis-) (Line 283)
  - 4.1 Query/Database Operations (Line 287)
  - 4.2 Caching Effectiveness (Line 308)
  - 4.3 Loop Efficiency (Line 314)
- [**STEP 5: Integration Verification**](#step-5-integration-verification-) (Line 337)
  - 5.1 Architecture Pattern Compliance (Line 341)
  - 5.2 API Contract Compliance (Line 354)
  - 5.3 Dependency Verification (Line 360)
  - 5.4 Interface Design Compliance (Line 386)
  - 5.5 Backward Compatibility (Line 455)
- [**STEP 6: Error Handling Review**](#step-6-error-handling-review-) (Line 462)
  - 6.1 Error Wrapping and Context (Line 466)
  - 6.1.1 Silent Error Handling - CRITICAL CHECKS (Line 508)
  - 6.2 Fallback Behavior (Line 589)
  - 6.3 Resource Cleanup (Line 643)
- [**STEP 7: Code Readability and Maintainability**](#step-7-code-readability-and-maintainability-) (Line 682)
  - 7.1 Function Length and Complexity (Line 686)
  - 7.2 Separation of Concerns (Line 710)
  - 7.3 Code Duplication (Line 730)
  - 7.4 Naming Clarity (Line 750)
  - 7.5 Comment Formatting (MANDATORY) (Line 1075)
  - 7.6 Code Organization (Line 1094)

### **Pattern Detection & Techniques**
- [**Specific Patterns to Detect**](#-specific-patterns-to-detect-go-specific) (Line 681)
  - Pattern 1: Loaded But Not Used (Line 683)
  - Pattern 2: Fetched Twice (Line 694)
  - Pattern 3: Parameter Mismatch (Line 705)
  - Pattern 4: Missing Return Value / Error Ignored (Line 716)
  - Pattern 5: Response Body Not Closed (Line 745)
  - Pattern 6: Nil Pointer Without Check (Line 757)
  - Pattern 7: Context Not Propagated (Line 765)
  - Pattern 8: God Interface Anti-Pattern (Line 778)
  - Pattern 9: fmt.Print Instead of Logger (Line 797)
  - Pattern 10: Code Readability Issues (Line 819)
  - Pattern 11: Over-Exporting / Internal Details Exposed (Line 897)
  - Pattern 12: Variable Shadowing with Named Returns (Line 940)
  - Pattern 13: Type Assertion Return Value Not Checked (Line 1364)
  - Pattern 14: String Literal Should Be Constant (Line 1390)
  - Pattern 15: Unused Function (Line 1410)
  - Pattern 16: Code Quality Issues - gocritic (Line 1430)
  - Pattern 17: Empty Branch (Line 1470)
- [**Systematic Tracing Technique**](#-systematic-tracing-technique-go-specific) (Line 821)

### **Quick Reference**
- [**Review Checklist Summary**](#-review-checklist-summary-go--project-specific) (Line 876)
- [**Success Criteria**](#-success-criteria) (Line 899)
- [**When to Apply This Protocol**](#-when-to-apply-this-protocol) (Line 911)
- [**Pro Tips**](#-pro-tips) (Line 924)
- [**Project-Specific Architecture Checks**](#-project-specific-architecture-checks) (Line 933)
  - 1. External API client isolation Violation (Line 937)
  - 2. Business Logic in CLI Command (Line 946)
  - 3. Direct Service Instantiation (Line 960)
  - 4. Domain Model Location Violation (Line 970)
  - 5. God Interface Anti-Pattern (Line 986)
  - 6. Error Not Wrapped (Line 1016)
  - 7. fmt.Print Instead of Logger (Line 1033)
  - 8. Silent Error Handling - State Persistence (Line 1050)
  - 9. Silent Error Handling - Session Refresh (Line 1069)
  - 10. HTTP Response Body Not Closed (Line 1097)
  - 11. Over-Exporting / Internal Details Exposed (Line 1112)

---

## ✅ **MANDATORY REVIEW STEPS**

### **STEP 1: Execution Flow Tracing** ⚡ CRITICAL

**Objective**: Trace how data and control flow through the code to find logical breaks.

#### **1.1 Entry Point Analysis**
- [ ] Identify the entry point(s) of the changed code (CLI command, service method, HTTP handler)
- [ ] Map the call chain: Who calls this? What does it call?
- [ ] Verify the flow follows architecture patterns (CLI → Service → Client/Repository)
- [ ] **RED FLAG**: Business logic in CLI command? → Should be in service layer
- [ ] **RED FLAG**: Direct External API client API calls outside `internal/clients/<service>/`? → Architecture violation

**Example Questions**:
```
Q: What function starts the process?
Q: What parameters does it receive?
Q: Where do those parameters come from?
Q: Does this follow the CLI → Service → Client pattern?
```

#### **1.2 Data Flow Tracking**
For EVERY variable/object created:
- [ ] Where is it created? (source)
- [ ] Where is it modified? (transformation points)
- [ ] Where is it consumed? (destination)
- [ ] **RED FLAG**: Variable created but never used? → BUG!
- [ ] **RED FLAG**: Variable used but never created? → BUG!
- [ ] **RED FLAG**: Variable passed through multiple layers unchanged? → Might be unused
- [ ] **RED FLAG**: Domain model mixed with infrastructure DTO? → Should be separated

**Technique**: Follow the variable name through the code path.

**Example (Go)**:
```go
// BAD: Variable created but never used
agents, err := client.ListAgents(ctx)  ← Created
if err != nil {
    return err
}
processData()  ← Never uses 'agents'!
→ BUG FOUND: agents is unused

// BAD: Domain model mixed with DTO
type Translation struct { /* domain model */ }
type Agent struct { /* ❌ WRONG! Infrastructure DTO */ }
→ Should be: Agent in internal/clients/<service>/models.go
```

#### **1.3 Function Call Verification**
For EVERY function call:
- [ ] What parameters are passed?
- [ ] What parameters does the function signature expect?
- [ ] **RED FLAG**: Parameter passed but function doesn't accept it? → BUG!
- [ ] **RED FLAG**: Required parameter missing? → BUG!
- [ ] **RED FLAG**: Function called but return value ignored? → Might be wasted work or error ignored
- [ ] **RED FLAG**: Context not passed to function that needs it? → Context propagation bug
- [ ] **RED FLAG**: Nil pointer passed where non-nil expected? → Potential panic

**Technique**: Jump to function definition, verify signature matches call site.

**Example (Go)**:
```go
// BAD: Context missing
client.CreateAgent(context.Background(), config)  // Missing ctx propagation
→ Should pass ctx from caller

// BAD: Error ignored
client.SendMessage(ctx, agentID, msgs)  // Error return value ignored!
→ Should handle error

// BAD: Nil passed to non-nil function
service.Process(nil)  // Function expects *Config
→ Potential panic
```

#### **1.4 Control Flow Verification**
- [ ] Does the code execute in the expected order?
- [ ] Are there missing return statements?
- [ ] Are error paths handled?
- [ ] **RED FLAG**: Code after `return` that never executes? → Dead code or bug
- [ ] **RED FLAG**: Error caught but not wrapped with domain error? → Missing error context
- [ ] **RED FLAG**: Defer called but resource not properly closed? → Resource leak
- [ ] **RED FLAG**: Context not checked for cancellation? → May waste resources

---

### **STEP 2: Resource Management Review** 💾

**Objective**: Ensure resources (memory, connections, files, HTTP response bodies) are properly managed.

#### **2.1 Memory Leaks**
- [ ] Are large objects kept in memory unnecessarily?
- [ ] Are batch operations loading more than needed?
- [ ] **RED FLAG**: Data loaded twice (batch + individual)? → Memory waste
- [ ] **RED FLAG**: Map/slice populated but never consumed? → Memory leak
- [ ] **RED FLAG**: Large structs passed by value instead of pointer? → Unnecessary copying

**Example Pattern to Detect (Go)**:
```go
// BAD: Loads data but doesn't use it
agents, err := client.ListAgents(ctx)  // ← Loads into memory
if err != nil {
    return err
}
processItems(items)  // ← Doesn't use 'agents', fetches again!
→ BUG FOUND: agents is unused

// BAD: Large struct passed by value
func process(s Saying) {  // Should be *Saying
→ Memory waste
```

#### **2.2 Database/Connection Management**
- [ ] Are database connections from pool returned properly? (pgxpool handles this automatically)
- [ ] Are transactions committed/rolled back? (defer tx.Rollback() used?)
- [ ] Are HTTP response bodies closed with defer? → **CRITICAL**
- [ ] **RED FLAG**: resp.Body.Close() missing? → Resource leak
- [ ] **RED FLAG**: Transaction not rolled back on error? → Data inconsistency
- [ ] **RED FLAG**: Context timeout not set for long operations? → Hanging requests
- [ ] **RED FLAG**: LLM/external API calls inside database transactions? → **CRITICAL - Causes blocking and performance issues**

**Example (Go)**:
```go
// BAD: Response body not closed
resp, err := client.doRequest(ctx, "GET", "/v1/agents", nil)
agents := []Agent{}
json.NewDecoder(resp.Body).Decode(&agents)  // ← resp.Body never closed!
→ BUG: Resource leak

// GOOD: Response body closed
resp, err := client.doRequest(ctx, "GET", "/v1/agents", nil)
if err != nil {
    return err
}
defer resp.Body.Close()  // ← Properly closed

// ❌ BAD: LLM call inside transaction - BLOCKS DATABASE
func (s *Service) ReviewHumanAlignment(ctx context.Context, evaluationID uuid.UUID, humanAgrees bool) error {
    return s.transactionManager.WithTransaction(ctx, func(db database.Transaction) error {
        evaluation, err := s.reviewRepo.GetByID(ctx, db, evaluationID)
        // ... update evaluation ...
        
        // ❌ WRONG: LLM call inside transaction - holds DB connection during slow API call
        for i := range evaluation.CriterionEvaluations {
            if err := s.ProposeCriterionScoreWithAlignment(ctx, ...); err != nil {
                return err  // Transaction held open during multiple slow LLM calls!
            }
        }
        
        return s.reviewRepo.Update(ctx, db, evaluation)
    })
}

// ✅ GOOD: LLM calls outside transaction, only DB write in transaction
func (s *Service) ReviewHumanAlignment(ctx context.Context, evaluationID uuid.UUID, humanAgrees bool) error {
    // Read outside transaction
    evaluation, err := s.reviewRepo.GetByID(ctx, nil, evaluationID)
    if err != nil {
        return err
    }
    
    // Do LLM calls OUTSIDE transaction (fast, non-blocking)
    for i := range evaluation.CriterionEvaluations {
        if err := s.ProposeCriterionScoreWithAlignment(ctx, ...); err != nil {
            return err
        }
    }
    
    // Only wrap DB write in transaction (fast operation)
    return s.transactionManager.WithTransaction(ctx, func(db database.Transaction) error {
        // Re-read to prevent race conditions
        currentEvaluation, err := s.reviewRepo.GetByID(ctx, db, evaluationID)
        // ... apply updates and save ...
        return s.reviewRepo.Update(ctx, db, currentEvaluation)
    })
}
```

#### **2.3 Context Management**
- [ ] Is context passed through all function calls?
- [ ] Is context checked for cancellation before expensive operations?
- [ ] **RED FLAG**: Context created but cancellation function not called? → Context leak
- [ ] **RED FLAG**: Background context used where request context should be? → Missing cancellation

**Example (Go)**:
```go
// BAD: Background context in request handler
ctx := context.Background()  // ← Should use request context
client.SendMessage(ctx, agentID, msgs)

// GOOD: Context with timeout
ctx, cancel := context.WithTimeout(parentCtx, 5*time.Second)
defer cancel()  // ← Always cancel
client.SendMessage(ctx, agentID, msgs)
```

---

### **STEP 3: Logic Verification** 🧠

**Objective**: Verify the code logic matches the intended behavior.

#### **3.1 Algorithm Correctness**
- [ ] Does the algorithm solve the stated problem?
- [ ] Are edge cases handled (empty slices, nil pointers, zero values)?
- [ ] Are boundary conditions checked?
- [ ] **RED FLAG**: Assumes data exists without nil checks? → Potential panic
- [ ] **RED FLAG**: Array/slice index out of bounds? → Panic risk
- [ ] **RED FLAG**: Map access without existence check? → Zero value confusion

**Example (Go)**:
```go
// BAD: Nil pointer dereference
var config *Config
config.Timeout = 5  // ← Panic: nil pointer dereference

// BAD: Index out of bounds
items[0] = value  // ← Panic if len(items) == 0

// BAD: Map access without check
weight := weights[agentName]  // ← Returns 0 if not found, might be unintended
```

#### **3.2 State Consistency**
- [ ] Are state variables updated correctly?
- [ ] Are there race conditions (if using goroutines)?
- [ ] **RED FLAG**: State modified but old state still used? → Stale data bug
- [ ] **RED FLAG**: Shared state accessed without mutex? → Race condition
- [ ] **RED FLAG**: Interface implementation not verified? → Runtime panic

**Example (Go)**:
```go
// BAD: Race condition
type Service struct {
    count int  // ← Accessed without mutex
}

// GOOD: Interface verification
var _ ClientInterface = (*Client)(nil)  // ← Compile-time check
```

#### **3.3 Side Effects**
- [ ] Are unintended side effects introduced?
- [ ] Does the code modify injected dependencies unexpectedly?
- [ ] **RED FLAG**: Function promises "read-only" but modifies state? → Bug
- [ ] **RED FLAG**: Service modifies client state? → Architecture violation
- [ ] **RED FLAG**: Variable shadowing with named returns? → Defer sees wrong error value (see Pattern 11)

---

### **STEP 4: Performance Analysis** ⚡

**Objective**: Identify performance bottlenecks and inefficiencies.

#### **4.1 Query/Database Operations**
- [ ] Are queries optimized (batch vs N+1)?
- [ ] **RED FLAG**: Loop with individual queries? → N+1 problem
- [ ] **RED FLAG**: Batch query performed but results unused? → Wasted work
- [ ] **RED FLAG**: Connection pool exhausted? → Check MaxConns configuration

**Example (Go)**:
```go
// BAD: N+1 query problem
for _, id := range ids {
    agent, _ := repo.GetByID(ctx, id)  // ← N queries!
    process(agent)
}

// GOOD: Batch query
agents, _ := repo.GetByIDs(ctx, ids)  // ← Single query
for _, agent := range agents {
    process(agent)
}
```

#### **4.2 Caching Effectiveness**
- [ ] Are cached values actually used?
- [ ] **RED FLAG**: Cache populated but bypassed? → Wasted computation
- [ ] **RED FLAG**: Cache key computed but value never retrieved? → Inefficient
- [ ] **RED FLAG**: Map lookup done multiple times for same key? → Should cache in variable

#### **4.3 Loop Efficiency**
- [ ] Are nested loops necessary?
- [ ] Can operations be batched?
- [ ] **RED FLAG**: O(n²) algorithm when O(n) is possible? → Performance bug
- [ ] **RED FLAG**: Slices reallocated in loop? → Use pre-allocation

**Example (Go)**:
```go
// BAD: Reallocation in loop
var items []Item
for i := 0; i < 1000; i++ {
    items = append(items, Item{i})  // ← Multiple reallocations
}

// GOOD: Pre-allocate
items := make([]Item, 0, 1000)  // ← Pre-allocated capacity
for i := 0; i < 1000; i++ {
    items = append(items, Item{i})
}
```

---

### **STEP 5: Integration Verification** 🔗

**Objective**: Ensure new code integrates properly with existing systems and follows architecture.

#### **5.1 Architecture Pattern Compliance** 🏗️
- [ ] **External API client isolation**: Are all External API client API calls through `internal/clients/<service>/`?
- [ ] **Service Layer**: Is business logic in `internal/services/` not in CLI commands?
- [ ] **Dependency Injection**: Are dependencies injected via constructor, not instantiated directly?
- [ ] **Domain Models**: Are domain models (Saying, Translation) in `internal/database/models.go`?
- [ ] **Infrastructure DTOs**: Are DTOs (Agent, Tool) in `internal/clients/<service>/models.go`?
- [ ] **Interface Design**: Are interfaces focused and small (5-6 methods max)?
- [ ] **RED FLAG**: Direct External API client API calls outside client? → Architecture violation
- [ ] **RED FLAG**: Business logic in CLI command? → Should be in service layer
- [ ] **RED FLAG**: Service instantiates client directly? → Should use DI
- [ ] **RED FLAG**: Interface with 10+ methods? → God Interface anti-pattern
- [ ] **RED FLAG**: Clients depend on interface methods they don't use? → ISP violation

#### **5.2 API Contract Compliance**
- [ ] Does the function match its documented signature?
- [ ] Are all required parameters provided?
- [ ] **RED FLAG**: Function signature changed but callers not updated? → Breaking change
- [ ] **RED FLAG**: Interface method added but implementation missing? → Compile error

#### **5.3 Dependency Verification**
- [ ] Are all required dependencies injected/provided?
- [ ] Are nil checks performed for critical dependencies?
- [ ] **RED FLAG**: Dependency required but not provided? → Runtime error/panic
- [ ] **RED FLAG**: Logger/client not injected? → Should use constructor injection

**Example (Go)**:
```go
// BAD: Direct instantiation
func NewService() *Service {
    client := client.NewClient(...)  // ← Should be injected!
    return &Service{client: client}
}

// GOOD: Dependency injection
func NewService(apiClient client.ClientInterface, logger *observability.Logger) *Service {
    if apiClient == nil {
        panic("apiClient cannot be nil")  // ← Validates dependency
    }
    return &Service{
        apiClient: apiClient,
        logger:      logger,
    }
}
```

#### **5.4 Interface Design Compliance** 🎯
- [ ] **Interface Size**: Does the interface have 5-6 methods or fewer?
- [ ] **Interface Focus**: Does the interface serve a single, cohesive purpose?
- [ ] **Interface Segregation**: Do clients only depend on methods they actually use?
- [ ] **RED FLAG**: Interface with 10+ methods? → **God Interface anti-pattern - violates ISP**
- [ ] **RED FLAG**: Single interface covering multiple entities (Saying + Translation + Evaluation)? → Should be segregated
- [ ] **RED FLAG**: Client uses only 2 methods from 15-method interface? → ISP violation

**Example (Go)**:
```go
// ❌ BAD: God Interface - 25+ methods, violates ISP
type Repository interface {
    // Saying operations
    CreateSaying(ctx context.Context, saying *Saying) error
    GetSayingByID(ctx context.Context, id uuid.UUID) (*Saying, error)
    UpdateSaying(ctx context.Context, saying *Saying) error
    DeleteSaying(ctx context.Context, id uuid.UUID) error
    
    // Translation operations
    CreateTranslation(ctx context.Context, translation *Translation) error
    GetTranslationByID(ctx context.Context, id uuid.UUID) (*Translation, error)
    UpdateTranslation(ctx context.Context, translation *Translation) error
    DeleteTranslation(ctx context.Context, id uuid.UUID) error
    
    // Evaluation operations
    CreateEvaluation(ctx context.Context, evaluation *Evaluation) error
    GetEvaluationByID(ctx context.Context, id uuid.UUID) (*Evaluation, error)
    UpdateEvaluation(ctx context.Context, evaluation *Evaluation) error
    DeleteEvaluation(ctx context.Context, id uuid.UUID) error
    
    // 20+ more methods...
}
// → BUG: TranslationService forced to depend on Saying/Evaluation methods it doesn't use!

// ✅ GOOD: Segregated interfaces - focused and small
type SayingRepository interface {
    Create(ctx context.Context, saying *Saying) error
    GetByID(ctx context.Context, id uuid.UUID) (*Saying, error)
    Update(ctx context.Context, saying *Saying) error
    Delete(ctx context.Context, id uuid.UUID) error
}

type TranslationRepository interface {
    Create(ctx context.Context, translation *Translation) error
    GetByID(ctx context.Context, id uuid.UUID) (*Translation, error)
    Update(ctx context.Context, translation *Translation) error
    Delete(ctx context.Context, id uuid.UUID) error
}

type EvaluationRepository interface {
    Create(ctx context.Context, evaluation *Evaluation) error
    GetByID(ctx context.Context, id uuid.UUID) (*Evaluation, error)
    Update(ctx context.Context, evaluation *Evaluation) error
    Delete(ctx context.Context, id uuid.UUID) error
}

// ✅ GOOD: Services only depend on what they use
type TranslationService struct {
    sayings      SayingRepository      // Only saying operations
    translations TranslationRepository // Only translation operations
}
```

**Detection Techniques**:
- Count methods in interface definition: `grep -A 50 "type.*interface" file.go | grep "func" | wc -l`
- Check if interface has 10+ methods → God Interface
- Verify clients use all methods or only subset → ISP violation if subset
- Look for interfaces named `Repository`, `Service`, `Client` with many methods → Likely god interface

#### **5.5 Backward Compatibility**
- [ ] Does this break existing functionality?
- [ ] Are default values provided for new parameters?
- [ ] **RED FLAG**: Required parameter added without default? → Breaking change

---

### **STEP 6: Error Handling Review** 🛡️

**Objective**: Ensure errors are handled gracefully with proper wrapping and context.

#### **6.1 Error Wrapping and Context**
- [ ] Are errors wrapped with domain errors using `errors.NewDomainError()`?
- [ ] Are underlying errors preserved (error wrapping)?
- [ ] Are error messages helpful and contextual?
- [ ] **RED FLAG**: Generic `error` returned without wrapping? → Missing context
- [ ] **RED FLAG**: Error ignored with `_ =`? → **BAD PRACTICE - Silent failure**
- [ ] **RED FLAG**: Error logged but not returned? → **BAD PRACTICE - Caller doesn't know it failed**
- [ ] **RED FLAG**: `fmt.Print`, `fmt.Printf`, `fmt.Println` used instead of logger? → **BAD PRACTICE - Bypasses structured logging**

**Example (Go)**:
```go
// BAD: Error not wrapped
resp, err := client.doRequest(ctx, "GET", "/v1/agents", nil)
if err != nil {
    return err  // ← Missing domain context
}

// GOOD: Error wrapped with domain error
resp, err := client.doRequest(ctx, "GET", "/v1/agents", nil)
if err != nil {
    return errors.NewDomainError(
        errors.ErrExternalAPI,
        "Failed to list agents",
        err,
    )
}

// BAD: Error ignored
_ = client.DeleteAgent(ctx, agentID)  // ← BAD PRACTICE: Silent failure!

// BAD: Error logged but not returned
if err := process(); err != nil {
    logger.Error(err)  // ← BAD PRACTICE: Caller doesn't know it failed!
}

// BAD: fmt.Print instead of logger
fmt.Printf("Saying created: %s\n", saying.ID)  // ← BAD PRACTICE: Bypasses structured logging!

// GOOD: Use logger for all output
logger.WithField("saying_id", saying.ID).Info("Saying created successfully")
```

#### **6.1.1 Silent Error Handling - CRITICAL CHECKS** 🚨
- [ ] **State Persistence Errors**: Are errors from state persistence operations (AddVersion, UpdateSession, etc.) returned, not silently ignored?
- [ ] **Session Refresh Errors**: Are errors from session/context refresh operations returned, not silently ignored?
- [ ] **RED FLAG**: State persistence error logged but not returned? → **CAUSES STATE INCONSISTENCY AND INFINITE LOOPS**
- [ ] **RED FLAG**: Session refresh error silently ignored? → **CAUSES STALE STATE AND VERSION CONFLICTS**
- [ ] **RED FLAG**: Error in critical path (state updates) that could cause data inconsistency? → **MUST RETURN ERROR**

**Why This Matters**:
- **State inconsistency**: Ignoring persistence errors causes in-memory and persisted state to diverge
- **Infinite loops**: Stale state causes version conflicts and repeated operations
- **Data corruption**: Ignored errors can lead to inconsistent database state
- **Silent failures**: Hidden bugs make debugging impossible

**Example (Go) - CRITICAL ANTI-PATTERNS**:
```go
// ❌ BAD: State persistence error silently ignored - CAUSES INFINITE LOOPS
if err := contextService.AddTranslationVersion(ctx, evalContext, version, translation, ...); err != nil {
    logger.Error(err)  // ← BAD PRACTICE: State is now inconsistent!
    // Don't fail the evaluation, just log the error  // ← WRONG!
    // Next iteration will have wrong version number → infinite loop!
}

// ❌ BAD: Session refresh error silently ignored - CAUSES STALE STATE
updatedContext, err := contextService.GetEvaluationContext(ctx, sayingID)
if err == nil && updatedContext != nil {
    // Update session...
}
// Error silently ignored - BAD PRACTICE: Session state is stale!
// CurrentVersion might be wrong → version conflicts!

// ❌ BAD: Error checked but not handled
if err := persistState(); err != nil {
    // Empty block - error ignored!  // ← BAD PRACTICE!
}

// ✅ GOOD: State persistence errors MUST be returned
if err := contextService.AddTranslationVersion(ctx, evalContext, version, translation, ...); err != nil {
    logger.WithError(err).Error("Failed to persist evaluation results to shared context")
    return errors.NewDomainError(
        errors.ErrExternalAPI,
        "Evaluation succeeded but failed to persist results - context state is inconsistent",
        err,
    )
}

// ✅ GOOD: Session refresh errors MUST be returned
updatedContext, err := contextService.GetEvaluationContext(ctx, sayingID)
if err != nil {
    logger.WithError(err).Error("Failed to refresh session state - session may have stale data")
    return errors.NewDomainError(
        errors.ErrExternalAPI,
        "Failed to refresh session state - session state is stale and unreliable",
        err,
    )
}
if updatedContext == nil {
    return errors.NewDomainError(
        errors.ErrExternalAPI,
        "Session refresh returned nil - session state is unreliable",
        nil,
    )
}
// Update session with fresh data...

// ✅ GOOD: All errors explicitly handled
if err := persistState(); err != nil {
    logger.WithError(err).Error("Failed to persist state - state is inconsistent")
    return errors.NewDomainError(
        errors.ErrStatePersistenceFailed,
        "Failed to persist state - state is now inconsistent",
        err,
    )
}
```

**Detection Patterns for Silent Errors**:
- Search for: `if err != nil { logger.Error(err) }` without return → Silent failure
- Search for: `_ = functionCall()` → Explicitly ignored error
- Search for: `err == nil &&` followed by usage without error check → Potential silent failure
- Search for: State persistence functions (AddVersion, UpdateSession, etc.) with error ignored → Critical bug

#### **6.2 Fallback Behavior**
- [ ] Is there fallback when operations fail?
- [ ] **RED FLAG**: Error in operation, no fallback? → Partial failure
- [ ] **RED FLAG**: Error in transaction, transaction not rolled back? → Data inconsistency
- [ ] **RED FLAG**: Fallback logic for database queries within transactions? → **NEVER DO THIS - Must fail fast and rollback**
- [ ] **RED FLAG**: `if err == nil` pattern to ignore database query failures? → **BAD PRACTICE - Must return errors**
- [ ] **RED FLAG**: LLM/external API calls inside database transactions? → **CRITICAL - Causes blocking and performance issues**

**Critical Rule 1**: **NEVER** implement fallback logic for database queries within transactions. If a database query fails, the transaction MUST rollback. Continuing with incomplete data violates transaction integrity.

**Critical Rule 2**: **NEVER** make LLM calls or external API calls inside database transactions. Transactions should be as short as possible and only wrap database operations. LLM/external API calls can take seconds and will block database connections, causing performance issues and connection pool exhaustion.

**Example (Go)**:
```go
// ❌ BAD: Fallback for database query - CAUSES DATA INCONSISTENCY
func (s *Service) ProcessSaying(ctx context.Context, sayingID uuid.UUID) error {
    return s.transactionManager.WithTransaction(ctx, func(tx database.Transaction) error {
        evaluations, err := tx.GetEvaluationsByContentID(ctx, contentID)
        if err == nil && len(evaluations) > 0 {
            // Use evaluations
        }
        // ❌ Problem: If query fails, we continue with incomplete data
        // ❌ Problem: Transaction state may be corrupted
        
        // ❌ BAD: Fallback to default value
        existingItems, err := tx.GetItems(ctx, id)
        if err != nil {
            return s.processWithDefault(ctx, tx, defaultValue)  // ← WRONG!
        }
        
        return nil
    })
}

// ✅ GOOD: Return errors immediately - transaction will rollback
func (s *Service) ProcessSaying(ctx context.Context, sayingID uuid.UUID) error {
    return s.transactionManager.WithTransaction(ctx, func(tx database.Transaction) error {
        evaluations, err := tx.GetEvaluationsByContentID(ctx, contentID)
        if err != nil {
            s.logger.WithError(err).Error("Failed to query evaluations within transaction")
            return errors.NewDomainError(
                errors.ErrEvaluationQueryFailed,
                "Failed to query evaluations",
                err,
            )
        }
        // ✅ Transaction will rollback automatically on error return
        
        if len(evaluations) > 0 {
            // Use evaluations
        }
        
        return nil
    })
}
```

**Example: LLM Calls Inside Transactions (CRITICAL ANTI-PATTERN)**:
```go
// ❌ BAD: LLM call inside transaction - BLOCKS DATABASE CONNECTION
func (s *HumanReviewService) ReviewCriterionProposal(ctx context.Context, evaluationID uuid.UUID, ...) error {
    return s.transactionManager.WithTransaction(ctx, func(db database.Transaction) error {
        evaluation, err := s.reviewRepo.GetByID(ctx, db, evaluationID)
        // ... update evaluation ...
        
        // ❌ WRONG: LLM refinement call inside transaction
        // This can take 2-5 seconds, holding the DB connection the entire time!
        if err := s.RefineProposal(ctx, evaluation, criterionEval); err != nil {
            return err
        }
        
        // ❌ Problem: Database connection held during slow LLM API call
        // ❌ Problem: Blocks other operations from using that connection
        // ❌ Problem: Can cause connection pool exhaustion under load
        
        return s.reviewRepo.Update(ctx, db, evaluation)
    })
}

// ✅ GOOD: LLM call outside transaction, only DB write in transaction
func (s *HumanReviewService) ReviewCriterionProposal(ctx context.Context, evaluationID uuid.UUID, ...) error {
    // Read evaluation outside transaction (uses connection pool, fast)
    evaluation, err := s.reviewRepo.GetByID(ctx, nil, evaluationID)
    if err != nil {
        return err
    }
    
    // Do LLM refinement OUTSIDE transaction (can take seconds, doesn't block DB)
    if err := s.RefineProposal(ctx, evaluation, criterionEval); err != nil {
        return err
    }
    
    // Only wrap DB write in transaction (fast operation, minimal blocking)
    return s.transactionManager.WithTransaction(ctx, func(db database.Transaction) error {
        // Re-read to prevent race conditions
        currentEvaluation, err := s.reviewRepo.GetByID(ctx, db, evaluationID)
        // ... apply updates ...
        return s.reviewRepo.Update(ctx, db, currentEvaluation)
    })
}
```

**Pattern to Follow**:
1. Read data outside transaction (or in short read-only transaction)
2. Perform LLM/external API calls outside transaction
3. Wrap only the final database write in a transaction
4. Re-read within transaction to prevent race conditions

#### **6.3 Resource Cleanup**
- [ ] Are resources cleaned up even on errors? (defer statements)
- [ ] **RED FLAG**: Response body not closed on error path? → Resource leak
- [ ] **RED FLAG**: Transaction not rolled back on error? → Database lock

**Example (Go)**:
```go
// BAD: Resource not cleaned up on error
resp, err := client.doRequest(ctx, "GET", "/v1/agents", nil)
if err != nil {
    return err  // ← resp.Body not closed!
}

// GOOD: Defer cleanup
resp, err := client.doRequest(ctx, "GET", "/v1/agents", nil)
if err != nil {
    return err
}
defer resp.Body.Close()  // ← Always closes, even on error

// GOOD: Transaction rollback
func (tm *TransactionManagerImpl) WithTransaction(ctx context.Context, fn func(tx Transaction) error) error {
    tx, err := tm.pool.Begin(ctx)
    if err != nil {
        return err
    }
    defer tx.Rollback(ctx)  // ← Always rolls back unless committed
    
    if err := fn(dbTx); err != nil {
        return err  // ← Rollback happens via defer
    }
    
    return tx.Commit(ctx)
}
```

---

### **STEP 7: Code Readability and Maintainability** 📖

**Objective**: Ensure code is clean, readable, and maintainable for future developers.

#### **7.1 Function Length and Complexity**
- [ ] Are functions focused on a single responsibility?
- [ ] Are functions too long (100+ lines)? → Should be broken down
- [ ] Are there deeply nested conditionals (3+ levels)? → Should be extracted
- [ ] **RED FLAG**: Function does multiple unrelated things? → Split into smaller functions
- [ ] **RED FLAG**: Large goroutine with complex logic? → Extract to separate function
- [ ] **RED FLAG**: Long parameter lists (5+ parameters)? → Consider struct parameter

**Example (Go)**:
```go
// BAD: Function too long and does multiple things
func runWithPTerm(ctx context.Context, cmd *cobra.Command, args []string, appContainer *container.Container, logger *observability.Logger, eventChan streaming.EventChannel, processingErrChan chan error) error {
    // 80+ lines of mixed logic: goroutine setup, error handling, event sending
    go func() {
        // Complex nested logic...
        if len(args) > 0 {
            // UUID parsing, error handling, processing...
        } else {
            // Different processing path...
        }
        // More complex logic...
    }()
    // More code...
}

// GOOD: Inlined goroutine, fail-fast error handling, single channel
RunE: func(cmd *cobra.Command, args []string) (err error) {
    ctx, cancel := context.WithCancel(ctx)
    defer cancel()
    
    eventChan := make(streaming.EventChannel, 100)
    
    // Start processing goroutine (inlined - no separate function needed)
    go func() {
        defer close(eventChan)
        var processingErr error
        if len(args) > 0 {
            processingErr = processSpecificSaying(ctx, args[0], appContainer, logger, eventChan)
        } else {
            processingErr = processNextSaying(ctx, appContainer, logger, eventChan)
        }
        if processingErr != nil {
            sendErrorEvent(ctx, eventChan, processingErr)
        }
    }()
    
    // Stream events and fail fast on error (inlined - no separate function needed)
    handler := tui.NewPTermHandler()
    for event := range eventChan {
        handler.HandleEvent(event)
        if event.Type == streaming.EventTypeError {
            logger.WithError(event.Error).Error("Failed to process translation")
            return event.Error  // Fail fast: return immediately
        }
    }
    
    logger.Info("Translation processing completed successfully")
    return nil
}

func processSpecificSaying(...) error {
    // Focused: Only handles specific saying processing
}

func processNextSaying(...) error {
    // Focused: Only handles next saying processing
}

func sendErrorEvent(...) {
    // Focused: Only sends error events
}
```

#### **7.2 Separation of Concerns**
- [ ] Is business logic separated from orchestration?
- [ ] Are helper functions extracted for reusable logic?
- [ ] **RED FLAG**: CLI command contains business logic? → Move to service layer
- [ ] **RED FLAG**: Service contains HTTP client details? → Move to client layer
- [ ] **RED FLAG**: Function handles both error creation and event sending? → Split responsibilities

**Example (Go)**:
```go
// BAD: Mixed concerns - error handling, event sending, and processing in one function
func runWithPTerm(...) error {
    go func() {
        // ... processing logic ...
        if processingErr != nil {
            select {
            case eventChan <- streaming.InferenceEvent{
                Type:      streaming.EventTypeError,
                Error:     processingErr,
                Timestamp: time.Now(),
            }:
            case <-ctx.Done():
            }
        }
        // ... more mixed logic ...
    }()
}

// GOOD: Inlined goroutine, fail-fast error handling, single channel
RunE: func(cmd *cobra.Command, args []string) (err error) {
    ctx, cancel := context.WithCancel(ctx)
    defer cancel()
    
    eventChan := make(streaming.EventChannel, 100)
    
    // Start processing goroutine (inlined - no separate function needed)
    go func() {
        defer close(eventChan)
        // ... processing logic ...
    }()
    
    // Stream events and fail fast on error (no separate function needed)
    handler := tui.NewPTermHandler()
    for event := range eventChan {
        handler.HandleEvent(event)
        if event.Type == streaming.EventTypeError {
            return event.Error  // Fail fast: return immediately
        }
    }
    return nil
}

func sendErrorEvent(ctx context.Context, eventChan streaming.EventChannel, err error) {
    // Single responsibility: Send error event
    select {
    case eventChan <- streaming.InferenceEvent{
        Type:      streaming.EventTypeError,
        Error:     err,
        Timestamp: time.Now(),
    }:
    case <-ctx.Done():
    }
}
```

#### **7.3 Code Duplication**
- [ ] Is the same logic repeated in multiple places?
- [ ] Are error event creation patterns duplicated? → Extract helper function
- [ ] Are validation patterns repeated? → Extract validation function
- [ ] **RED FLAG**: Same select statement pattern repeated? → Extract helper
- [ ] **RED FLAG**: Similar error handling code duplicated? → Extract function
- [ ] **RED FLAG**: Error sent to multiple channels? → Use single channel and track from event stream

**Example (Go)**:
```go
// BAD: Duplicated error event sending
func processSpecificSaying(...) error {
    // ...
    if err != nil {
        select {
        case eventChan <- streaming.InferenceEvent{
            Type:      streaming.EventTypeError,
            Error:     err,
            Timestamp: time.Now(),
        }:
        case <-ctx.Done():
        }
        return err
    }
}

func processNextSaying(...) error {
    // ...
    if err != nil {
        select {
        case eventChan <- streaming.InferenceEvent{
            Type:      streaming.EventTypeError,
            Error:     err,
            Timestamp: time.Now(),
        }:
        case <-ctx.Done():
        }
        return err
    }
}

// GOOD: Extracted helper function
func sendErrorEvent(ctx context.Context, eventChan streaming.EventChannel, err error) {
    select {
    case eventChan <- streaming.InferenceEvent{
        Type:      streaming.EventTypeError,
        Error:     err,
        Timestamp: time.Now(),
    }:
    case <-ctx.Done():
    }
}

func processSpecificSaying(...) error {
    // ...
    if err != nil {
        sendErrorEvent(ctx, eventChan, err)
        return err
    }
}

func processNextSaying(...) error {
    // ...
    if err != nil {
        sendErrorEvent(ctx, eventChan, err)
        return err
    }
}

// BAD: Error sent to multiple channels (duplication)
func startProcessingGoroutine(...) {
    go func() {
        // ...
        if processingErr != nil {
            sendErrorEvent(ctx, eventChan, processingErr)  // Sent to eventChan
        }
        select {
        case processingErrChan <- processingErr:  // Also sent to processingErrChan
        case <-ctx.Done():
        }
    }()
}

// GOOD: Single channel, fail-fast error handling (no duplication, no separate functions)
RunE: func(cmd *cobra.Command, args []string) (err error) {
    ctx, cancel := context.WithCancel(ctx)
    defer cancel()
    
    eventChan := make(streaming.EventChannel, 100)
    
    // Inlined goroutine - no separate function needed
    go func() {
        defer close(eventChan)
        // ... processing ...
        if processingErr != nil {
            sendErrorEvent(ctx, eventChan, processingErr)
        }
    }()
    
    // Fail fast on error - no separate function needed
    handler := tui.NewPTermHandler()
    for event := range eventChan {
        handler.HandleEvent(event)
        if event.Type == streaming.EventTypeError {
            return event.Error  // Fail fast: return immediately
        }
    }
    return nil
}
```

#### **7.4 Naming Clarity**
- [ ] Are function names descriptive and action-oriented?
- [ ] Do variable names clearly indicate their purpose?
- [ ] **RED FLAG**: Generic names like `process`, `handle`, `do`? → Use specific names
- [ ] **RED FLAG**: Abbreviations that aren't clear? → Use full words
- [ ] **RED FLAG**: Names that don't match what the function does? → Rename for accuracy

#### **7.5 Comment Formatting (MANDATORY)**
- [ ] **ALL comments MUST end with a period (`.`)**
- [ ] **RED FLAG**: Comments without periods? → The `godot` linter will fail
- [ ] **Reference**: See `site-rules-for-golang-coding.mdc` → [**CRITICAL: Comment Formatting (MANDATORY)**](#-critical-comment-formatting-mandatory) (Line 506) for complete details, rationale, and examples.
- [ ] **Quick Summary**: Missing periods cause lint failures and waste time fixing trivial issues.

**Example (Go)**:
```go
// BAD: Generic, unclear names
func run(ctx context.Context, args []string, c *container.Container) error {
    // What does "run" do? Unclear.
}

func process(ctx context.Context, id string) error {
    // What does "process" mean? Too generic.
}

// GOOD: Specific, descriptive names
func runWithPTerm(ctx context.Context, args []string, appContainer *container.Container, logger *observability.Logger, eventChan streaming.EventChannel, processingErrChan chan error) error {
    // Clear: Runs translation process with PTerm UI
}

func processSpecificSaying(ctx context.Context, sayingIDStr string, appContainer *container.Container, logger *observability.Logger, eventChan streaming.EventChannel) error {
    // Clear: Processes a specific saying by ID
}

func processNextSaying(ctx context.Context, appContainer *container.Container, logger *observability.Logger, eventChan streaming.EventChannel) error {
    // Clear: Processes the next saying in queue
}
```

#### **7.6 Code Organization**
- [ ] Are related functions grouped together?
- [ ] Are helper functions placed near where they're used?
- [ ] Is the code flow easy to follow (top to bottom)?
- [ ] **RED FLAG**: Functions defined in random order? → Organize by call order or logical grouping
- [ ] **RED FLAG**: Large file with unrelated functions? → Consider splitting into multiple files
- [ ] **RED FLAG**: Unused parameters in function signatures? → Remove them

**Example (Go)**:
```go
// BAD: Functions in random order, unused parameters
func processNextSaying(...) error {
    // Uses processSayingWithStreaming
}

func NewTranslationCommand(...) *cobra.Command {
    // Entry point
}

func processSayingWithStreaming(...) error {
    // Used by processNextSaying and processSpecificSaying
}

func processSpecificSaying(...) error {
    // Uses processSayingWithStreaming
}

func runWithPTerm(cmd *cobra.Command, ...) error {  // cmd parameter never used!
    // Main orchestration
}

// GOOD: Organized by call order and logical grouping
// 1. Entry point
func NewTranslationCommand(...) *cobra.Command {
    // ...
}

// 2. Main orchestration
func runWithPTerm(ctx context.Context, args []string, ...) error {  // Removed unused cmd parameter
    // ...
}

// 3. Goroutine setup
func startProcessingGoroutine(...) {
    // ...
}

// 4. Processing functions (grouped by type)
func processSpecificSaying(...) error {
    // ...
}

func processNextSaying(...) error {
    // ...
}

// 5. Shared processing function
func processSayingWithStreaming(...) error {
    // ...
}

// 6. Helper functions (grouped together)
func sendErrorEvent(...) {
    // ...
}

func sendDoneEvent(...) {
    // ...
}
```

**Detection Techniques**:
- Count function lines: Functions over 50-100 lines may need refactoring
- Check nesting depth: More than 3 levels of nesting suggests complexity
- Look for repeated patterns: Same code structure repeated 2+ times → Extract function
- Verify parameter usage: Unused parameters should be removed
- Check function order: Functions should be organized logically (entry → orchestration → helpers)

---

## 🎯 **SPECIFIC PATTERNS TO DETECT (Go-Specific)**

### **Pattern 1: Loaded But Not Used** ⚠️
```go
// BAD: Loads data but doesn't use it
agents, err := client.ListAgents(ctx)
if err != nil {
    return err
}
processItems(items)  // Doesn't use 'agents'!
```
**Detection**: Variable created but never referenced after creation.

### **Pattern 2: Fetched Twice** ⚠️
```go
// BAD: Fetches same data twice
agents, _ := client.ListAgents(ctx)
for _, id := range agentIDs {
    agent, _ := client.GetAgent(ctx, id)  // Fetches again!
    process(agent)
}
```
**Detection**: Batch operation followed by individual operations on same data.

### **Pattern 3: Parameter Mismatch** ⚠️
```go
// BAD: Parameter passed but function doesn't accept it
result := function(param1, param2)  // Passes param2

func function(param1 string) error {  // Doesn't accept param2!
    return nil
}
```
**Detection**: Function call has different signature than definition (Go compiler catches this).

### **Pattern 4: Missing Return Value / Error Ignored** ⚠️ CRITICAL
```go
// BAD: Function returns value but caller ignores it
agents, _ := client.ListAgents(ctx)  // Error ignored!
process()  // Doesn't use 'agents' either!

// BAD: Error explicitly ignored
_ = client.DeleteAgent(ctx, agentID)  // BAD PRACTICE: Silent failure!

// BAD: State persistence error logged but not returned
if err := contextService.AddTranslationVersion(ctx, evalContext, ...); err != nil {
    logger.Error(err)  // BAD PRACTICE: State is now inconsistent!
    // Continue as if nothing happened → infinite loop risk!
}

// BAD: Session refresh error silently ignored
updatedContext, err := contextService.GetEvaluationContext(ctx, sayingID)
if err == nil && updatedContext != nil {
    // Update session...
}
// Error silently ignored - BAD PRACTICE: Session state is stale!
```
**Detection**: 
- Function call result assigned but variable never used, or error ignored
- **CRITICAL**: State persistence errors (AddVersion, UpdateSession) that are logged but not returned
- **CRITICAL**: Session refresh errors that are checked with `err == nil` but error path not handled
- Search for: `if err != nil { logger.Error(err) }` without return statement
- Search for: `_ = functionCall()` patterns

### **Pattern 5: Response Body Not Closed** ⚠️ CRITICAL
```go
// BAD: Response body not closed
resp, err := httpClient.Do(req)
if err != nil {
    return err
}
data := []byte{}
json.NewDecoder(resp.Body).Decode(&data)  // resp.Body never closed!
```
**Detection**: HTTP response obtained but `defer resp.Body.Close()` missing.

### **Pattern 6: Nil Pointer Without Check** ⚠️
```go
// BAD: Nil pointer dereference
var config *Config
timeout := config.Timeout  // Panic: nil pointer dereference
```
**Detection**: Pointer dereferenced without nil check.

### **Pattern 7: Context Not Propagated** ⚠️
```go
// BAD: Context not propagated
func Process() error {
    client.SendMessage(context.Background(), agentID, msgs)  // Should use request ctx
}

// BAD: Context created but not cancelled
ctx, cancel := context.WithTimeout(parentCtx, 5*time.Second)
defer cancel()  // Missing!
```
**Detection**: Context not passed through call chain, or cancellation function not deferred.

### **Pattern 8: God Interface Anti-Pattern** ⚠️
```go
// BAD: God Interface - 25+ methods
type Repository interface {
    CreateSaying(...)
    GetSayingByID(...)
    UpdateSaying(...)
    DeleteSaying(...)
    CreateTranslation(...)
    GetTranslationByID(...)
    // ... 20+ more methods
}
```
**Detection**: 
- Interface with 10+ methods → God Interface
- Single interface covering multiple entities → Should be segregated
- Clients depend on methods they don't use → ISP violation
- Count methods: `grep -A 50 "type.*interface" file.go | grep "func" | wc -l`

### **Pattern 9: fmt.Print Instead of Logger** ⚠️ CRITICAL
```go
// BAD: fmt.Print bypasses structured logging
fmt.Printf("Saying created: %s\n", saying.ID)
fmt.Println("Processing complete")
fmt.Print("Error occurred")

// BAD: fmt.Print for error messages
if err != nil {
    fmt.Printf("Error: %v\n", err)  // ← BAD PRACTICE: Should use logger!
}

// GOOD: Use logger for all output
logger.WithField("saying_id", saying.ID).Info("Saying created successfully")
logger.WithError(err).Error("Failed to process saying")
logger.Debug("Processing started")
```
**Detection**: 
- Search for: `fmt.Print`, `fmt.Printf`, `fmt.Println` in service/command code
- **Exception**: CLI user-facing output (success messages to terminal) may use `fmt.Print`, but logger is preferred for consistency
- **CRITICAL**: All error messages, debug info, and internal logging MUST use logger, never `fmt.Print`

### **Pattern 12: Variable Shadowing with Named Returns** ⚠️ CRITICAL
```go
// BAD: Variable shadowing causes defer to see wrong error value
func processCommand(cmd *cobra.Command, args []string) (err error) {
    defer observability.EndSpanWithStatus(otelSpan, err) // Will see nil, not the actual error!
    
    // ❌ WRONG: Creates new local 'err' that shadows named return
    if err := service.Process(ctx); err != nil {
        return fmt.Errorf("failed: %w", err)
    }
    return nil
    // Problem: defer sees named return 'err' which is still nil
    // Span status will be set to OK even though error occurred!
}

// BAD: Multiple shadowing issues
func parseAndProcess(sayingID string) (err error) {
    defer observability.EndSpanWithStatus(otelSpan, err)
    
    // ❌ WRONG: Creates new local 'err' that shadows named return
    id, err := uuid.Parse(sayingID)
    if err != nil {
        return fmt.Errorf("invalid ID: %w", err)
    }
    
    // ❌ WRONG: Also shadows named return
    if err := service.Process(id); err != nil {
        return fmt.Errorf("failed: %w", err)
    }
    return nil
}

// ✅ GOOD: Assign to named return value
func processCommand(cmd *cobra.Command, args []string) (err error) {
    defer observability.EndSpanWithStatus(otelSpan, err) // Will see the actual error
    
    // ✅ CORRECT: Assigns to named return 'err'
    if err = service.Process(ctx); err != nil {
        return fmt.Errorf("failed: %w", err)
    }
    return nil
    // defer correctly sees the error value and sets span status to ERROR
}

// ✅ GOOD: Explicit variable declaration, then assignment
func parseAndProcess(sayingID string) (err error) {
    defer observability.EndSpanWithStatus(otelSpan, err)
    
    // ✅ CORRECT: Declare id separately, assign to named return
    var id uuid.UUID
    id, err = uuid.Parse(sayingID)
    if err != nil {
        return fmt.Errorf("invalid ID: %w", err)
    }
    
    // ✅ CORRECT: Assign to named return
    if err = service.Process(id); err != nil {
        return fmt.Errorf("failed: %w", err)
    }
    return nil
}
```
**Detection**: 
- Function has named return value `(err error)`
- Function uses `defer` that references the named return (e.g., `defer observability.EndSpanWithStatus(otelSpan, err)`)
- Function uses `if err :=` or `id, err :=` which creates a new local variable that shadows the named return
- **Impact**: Defer function sees `nil` instead of the actual error, causing incorrect span status, resource cleanup, or error reporting

**Why This Matters**:
- **Incorrect observability**: Spans marked as OK when errors occurred
- **Silent failures**: Errors not properly reported or logged
- **Resource leaks**: Cleanup functions don't see errors and may not handle them correctly
- **Debugging difficulty**: Hard to trace why spans show success when errors occurred

### **Pattern 13: Type Assertion Return Value Not Checked** ⚠️
```go
// BAD: Type assertion return value (ok) not checked
humanComment, _ := alignment.Content["human_comment"].(string)  // ← errcheck: ok value ignored
pattern, _ := alignment.Content["pattern"].(string)            // ← errcheck: ok value ignored

// Problem: If type assertion fails, variable gets zero value (empty string)
// Code continues as if value exists, causing silent bugs

// GOOD: Check type assertion result
humanComment, ok := alignment.Content["human_comment"].(string)
if !ok {
    humanComment = ""  // Explicit default value
    // Or handle missing value appropriately
}

pattern, ok := alignment.Content["pattern"].(string)
if !ok {
    return fmt.Errorf("pattern field missing or wrong type")
}
```
**Detection**: 
- Search for: `value, _ := something.(type)` → Type assertion with ignored `ok` value
- **Impact**: Silent failures when type assertion fails, zero values used incorrectly
- **Rule**: Always check the `ok` return value from type assertions

### **Pattern 14: String Literal Should Be Constant** ⚠️
```go
// BAD: String literal repeated 3+ times
case "component_alignment":  // ← goconst: should be a constant
    // ...
case "component_alignment":  // Repeated
    // ...
case "component_alignment":  // Repeated again

// GOOD: Define as constant
const ArtifactTypeComponentAlignment = "component_alignment"

case ArtifactTypeComponentAlignment:
    // ...
case ArtifactTypeComponentAlignment:
    // ...
case ArtifactTypeComponentAlignment:
    // ...
```
**Detection**: 
- Search for: String literals that appear 3+ times in the same file
- **Impact**: Typos in string literals cause bugs, harder to refactor
- **Rule**: Extract string literals used 3+ times into constants
- **Tool**: `goconst` linter detects this automatically

### **Pattern 15: Unused Function** ⚠️
```go
// BAD: Function defined but never called
func validateRequiredFields(content map[string]interface{}, fields []string) bool {
    // ... implementation ...
    return true
}
// ← unused: Function never called anywhere

// Options:
// 1. Remove if truly unused
// 2. Use it if it was intended to be used
// 3. Export it if it should be used by other packages
```
**Detection**: 
- Search for: Functions defined but never called
- **Impact**: Dead code, maintenance burden, confusion about intent
- **Rule**: Remove unused functions or use them if they're needed
- **Tool**: `unused` linter detects this automatically

### **Pattern 16: Code Quality Issues - gocritic** ⚠️
```go
// BAD: Parameter type can be combined (paramTypeCombine)
func (c *SimilarityThresholdsConfig) GetThreshold(artifactType string, job string) float64 {
    // ← gocritic: Both parameters are string, can be combined
}

// GOOD: Combine parameter types
func (c *SimilarityThresholdsConfig) GetThreshold(artifactType, job string) float64 {
    // ...
}

// BAD: Range value copy (rangeValCopy)
for _, criterionEval := range evaluation.CriterionEvaluations {
    // ← gocritic: Copies 216 bytes per iteration
    criterionEval.Status = "updated"  // Doesn't modify original!
}

// GOOD: Use pointer or index
for i := range evaluation.CriterionEvaluations {
    evaluation.CriterionEvaluations[i].Status = "updated"  // Modifies original
}

// Or if you need the value:
for i, criterionEval := range evaluation.CriterionEvaluations {
    // Use criterionEval for reading
    evaluation.CriterionEvaluations[i].Status = "updated"  // Modify via index
}
```
**Detection**: 
- **paramTypeCombine**: Multiple consecutive parameters of same type → Combine them
- **rangeValCopy**: Range loop copies large structs → Use index or pointer
- **Impact**: Performance issues, bugs from modifying copies instead of originals
- **Tool**: `gocritic` linter detects these automatically

### **Pattern 17: Empty Branch** ⚠️
```go
// BAD: Empty if branch (staticcheck SA9003)
if chainOfThoughtModule != nil {
    // Empty block - no code here
}

// Options:
// 1. Remove if check is unnecessary
if chainOfThoughtModule != nil {
    // Actually do something with it
    chainOfThoughtModule.Process(ctx)
}

// 2. Remove the check if nil is acceptable
// Just use chainOfThoughtModule directly if nil is handled elsewhere

// 3. Add a comment explaining why the check exists
if chainOfThoughtModule != nil {
    // Module is optional, nil check for future use
    _ = chainOfThoughtModule  // Explicitly acknowledge we're checking but not using
}
```
**Detection**: 
- Search for: `if condition { }` with empty block
- **Impact**: Dead code, unclear intent, potential bugs
- **Rule**: Remove empty branches or add meaningful code/comments
- **Tool**: `staticcheck` SA9003 detects this automatically

### **Pattern 10: Code Readability Issues** ⚠️
```go
// BAD: Long function with mixed concerns
func runWithPTerm(ctx context.Context, cmd *cobra.Command, args []string, appContainer *container.Container, logger *observability.Logger, eventChan streaming.EventChannel, processingErrChan chan error) error {
    // 80+ lines mixing: goroutine setup, error handling, event sending, processing logic
    go func() {
        defer close(eventChan)
        defer close(processingErrChan)
        var processingErr error
        if len(args) > 0 {
            sayingID := args[0]
            logger.WithField("saying_id", sayingID).Info("Processing translation for specific saying...")
            var id uuid.UUID
            id, processingErr = uuid.Parse(sayingID)
            if processingErr != nil {
                select {
                case eventChan <- streaming.InferenceEvent{
                    Type:      streaming.EventTypeError,
                    Error:     processingErr,
                    Timestamp: time.Now(),
                }:
                case <-ctx.Done():
                    return
                }
                processingErrChan <- processingErr
                return
            }
            processingErr = processSayingWithStreaming(ctx, appContainer, id, eventChan)
        } else {
            logger.Info("Processing translation for next saying...")
            processingErr = processNextSayingWithStreaming(ctx, appContainer, eventChan)
        }
        if processingErr != nil {
            select {
            case eventChan <- streaming.InferenceEvent{
                Type:      streaming.EventTypeError,
                Error:     processingErr,
                Timestamp: time.Now(),
            }:
            case <-ctx.Done():
            }
        }
        select {
        case processingErrChan <- processingErr:
        case <-ctx.Done():
        }
    }()
    tui.StreamWithPTerm(eventChan)
    processingErr := <-processingErrChan
    if processingErr != nil {
        logger.WithError(processingErr).Error("Failed to process translation")
        return processingErr
    }
    logger.Info("Translation processing completed successfully")
    return nil
}

// GOOD: Inlined goroutine, fail-fast error handling, single channel
RunE: func(cmd *cobra.Command, args []string) (err error) {
    // ... validation ...
    
    ctx, cancel := context.WithCancel(ctx)
    defer cancel()
    
    eventChan := make(streaming.EventChannel, 100)
    
    // Start processing goroutine (inlined)
    go func() {
        defer close(eventChan)
        var processingErr error
        if len(args) > 0 {
            processingErr = processSpecificSaying(ctx, args[0], appContainer, logger, eventChan)
        } else {
            processingErr = processNextSaying(ctx, appContainer, logger, eventChan)
        }
        if processingErr != nil {
            sendErrorEvent(ctx, eventChan, processingErr)
        }
    }()
    
    // Stream events and fail fast on error
    handler := tui.NewPTermHandler()
    for event := range eventChan {
        handler.HandleEvent(event)
        if event.Type == streaming.EventTypeError {
            logger.WithError(event.Error).Error("Failed to process translation")
            return event.Error  // Fail fast: return immediately
        }
    }
    
    logger.Info("Translation processing completed successfully")
    return nil
}

func processSpecificSaying(...) error {
    // Focused: Only handles specific saying processing
}

func sendErrorEvent(...) {
    // Focused: Only sends error events
}
```
**Detection**: 
- Functions over 50-100 lines → May need refactoring
- Functions with 3+ levels of nesting → Complexity issue
- Repeated code patterns (2+ times) → Should be extracted
- Functions with mixed responsibilities → Should be split
- Unused parameters in function signatures → Should be removed
- Functions in random order → Should be organized logically
- **Note**: Simple functions used only once can be inlined for clarity (e.g., goroutine setup, event streaming)
- **Note**: Fail-fast error handling (return immediately on error) is preferred over tracking and returning later

### **Pattern 11: Over-Exporting / Internal Details Exposed** ⚠️
```go
// BAD: Internal implementation struct exported
type Orchestrator struct {  // ← Should be 'orchestrator' (lowercase)
    evaluationClient dspy.EvaluationClient
    logger           *observability.Logger
}

// BAD: Internal method exported
func (o *Orchestrator) EvaluateTranslation(...) {  // ← Should be 'evaluateTranslation'
    // Only used internally by service
}

// BAD: Internal interface exported
type OrchestratorInterface interface {  // ← Should be 'orchestratorInterface' or removed
    EvaluateTranslation(...)
}

// GOOD: Only public API exported
type ServiceInterface interface {  // ✅ Public API
    EvaluateTranslationResult(...)
}

func NewService(...) ServiceInterface {  // ✅ Constructor exported
    // ...
}

type Service struct {  // ✅ Can be exported if needed for testing, or private
    orchestrator *orchestrator  // ✅ Internal implementation private
}

type orchestrator struct {  // ✅ Internal struct private
    evaluationClient dspy.EvaluationClient
}

func (o *orchestrator) evaluateTranslation(...) {  // ✅ Internal method private
    // ...
}
```
**Detection**: 
- Search for exported structs/interfaces/methods that are only used within the package
- Check if internal implementation details are exported (lowercase = private, uppercase = public)
- **Rule**: Only export public API interfaces and constructors. Keep internal implementation private.
- **Verification**: `grep -r "^type [A-Z]" package/ | grep -v "Interface\|New"` → Check if these are used outside package
- **Verification**: `grep -r "^func [A-Z]" package/ | grep -v "New"` → Check if these are used outside package

---

## 🔍 **SYSTEMATIC TRACING TECHNIQUE (Go-Specific)**

### **For Each Function:**

1. **Read Sequentially**
   - Start at entry point (CLI command or service method)
   - Follow line by line
   - Note all variables created (pointers, slices, maps)
   - Check for nil checks before dereferencing

2. **Follow Function Calls**
   - When you see `function_call()`, jump to definition
   - Verify parameter match (types, number)
   - Check return value usage (especially errors)
   - Verify context is propagated
   - Check if dependencies are injected or directly instantiated

3. **Track Data Flow**
   ```
   Variable Lifecycle:
   Created → Modified → Used → Discarded
   ```
   - If stops at "Created" → Unused variable
   - If jumps "Used" → Variable used before creation (bug!)
   - Check if pointers are nil before use
   - Verify slices/maps are initialized

4. **Build Mental Model**
   ```
   Function Call Graph (Architecture):
   CLI Command
     └─ Service Layer
         ├─ External API client (HTTP)
         ├─ Repository (Database)
         └─ External Client
   ```
   - Look for disconnects in the graph
   - Missing connections = bugs
   - Verify architecture layers (no CLI → Client direct calls)

5. **Verify Contracts**
   - Function promises: "I will return X"
   - Caller expects: "I will receive X"
   - Match? Good. Mismatch? Bug.
   - Interface implementation verified? (`var _ Interface = (*Impl)(nil)`)
   - Error types match? (DomainError vs generic error)

6. **Check Resource Management**
   - HTTP responses: `defer resp.Body.Close()`
   - Database transactions: `defer tx.Rollback(ctx)`
   - Contexts: `defer cancel()`
   - Files: `defer file.Close()`

---

## 📋 **REVIEW CHECKLIST SUMMARY (Go + Project-Specific)**

After ANY code change, verify:

- [ ] **Data Flow**: Every variable is created AND used
- [ ] **Function Calls**: Parameters match signatures, context propagated
- [ ] **Resource Usage**: HTTP response bodies closed, transactions rolled back, contexts cancelled
- [ ] **Logic**: Algorithm matches intended behavior, nil checks present
- [ ] **Performance**: No redundant operations (fetch twice, etc.), slices pre-allocated
- [ ] **Architecture**: External API client calls through client, business logic in services, DI used
- [ ] **Interface Design**: Interfaces are focused and small (5-6 methods max), no god interfaces (10+ methods)
- [ ] **Interface Segregation**: Clients only depend on interface methods they use
- [ ] **Error Handling**: Errors wrapped with domain errors, not ignored
- [ ] **Silent Error Handling**: No errors silently ignored (`_ =`), no logged-but-not-returned errors
- [ ] **Variable Shadowing**: No variable shadowing with named returns (use `err =` not `err :=` when defer needs to see error)
- [ ] **State Persistence Errors**: All state persistence errors are returned, never silently ignored
- [ ] **Session Refresh Errors**: All session/context refresh errors are returned, never silently ignored
- [ ] **Database Query Errors**: No fallback logic for database queries within transactions
- [ ] **Logging Standards**: No `fmt.Print`/`fmt.Printf`/`fmt.Println` - use logger for all output
- [ ] **Domain Models**: Domain models in `internal/database/models.go`, DTOs with clients
- [ ] **Nil Safety**: Pointers checked before dereference, interfaces validated
- [ ] **Visibility Rules**: Only essential symbols exported (public API interfaces and constructors)
- [ ] **Internal Details Private**: Internal structs, interfaces, and methods are unexported (lowercase)
- [ ] **Code Readability**: Functions are focused and single-purpose, no duplication, clear naming
- [ ] **Comment Formatting**: ALL comments end with a period (`.`) - `godot` linter requirement
- [ ] **Code Organization**: Functions organized logically, unused parameters removed, related code grouped
- [ ] **Type Assertions**: Type assertion return values (`ok`) are checked, not ignored
- [ ] **String Constants**: String literals used 3+ times are extracted as constants
- [ ] **CLI Text Wrap Width**: Paragraph/wrap width uses `tui.DefaultTextWrapWidth` only; no duplicate constants or magic numbers (e.g. `MaxWidth: 120` instead of the shared constant)
- [ ] **Unused Code**: No unused functions, variables, or imports
- [ ] **Code Quality**: Parameter types combined when same type, range loops use indices for large structs
- [ ] **Empty Branches**: No empty if/else branches without comments or meaningful code

---

## 🎖️ **SUCCESS CRITERIA**

**You've done a good review when:**
- ✅ You can trace execution flow start to finish
- ✅ You understand where every piece of data goes
- ✅ You've identified at least one potential issue (even if minor)
- ✅ You've verified the code does what it claims to do

**Finding bugs is GOOD** - it means you're thorough, not that the code is bad.

---

## 🔄 **WHEN TO APPLY THIS PROTOCOL**

**ALWAYS apply this after:**
- Implementing new features
- Refactoring existing code
- Optimizing performance
- Fixing bugs (verify the fix doesn't break anything)
- Adding integration code

**Time Investment**: 5-10 minutes can save hours of debugging later.

---

## 💡 **PRO TIPS**

1. **Don't skip steps** - Each step catches different types of bugs
2. **Trust your instincts** - If something feels "off", investigate
3. **Document findings** - Note what you checked and what you found
4. **Celebrate bugs found** - Every bug found early is a win!

---

## 🏗️ **PROJECT-SPECIFIC ARCHITECTURE CHECKS**

### **Critical Architecture Violations to Detect:**

1. **External API client isolation Violation**
   ```go
   // ❌ BAD: Direct HTTP call outside client
   resp, err := http.Post("http://external-service:8283/v1/agents", ...)
   
   // ✅ GOOD: Through External API client client
   agent, err := apiClient.CreateAgent(ctx, config)
   ```

2. **Business Logic in CLI Command**
   ```go
   // ❌ BAD: Complex logic in CLI
   func (c *Command) Execute() {
       // ... complex agent creation logic ...
       // ... database queries ...
   }
   
   // ✅ GOOD: Delegates to service
   func (c *Command) Execute() {
       return c.service.CreateAgent(ctx, config)
   }
   ```

3. **Direct Service Instantiation**
   ```go
   // ❌ BAD: Direct instantiation
   client := client.NewClient(...)
   service := agent.NewService(client, logger)
   
   // ✅ GOOD: Dependency injection
   service := agent.NewService(apiClient, logger)  // Injected
   ```

4. **Domain Model Location Violation**
   ```go
   // ❌ BAD: Infrastructure DTO in domain models
   // internal/database/models.go
   type Saying struct { /* domain model */ }
   type Agent struct { /* ❌ WRONG! Should be in clients/<service>/models.go */ }
   
   // ✅ GOOD: Separated correctly
   // internal/database/models.go - Domain only
   type Saying struct { /* domain model */ }
   type Translation struct { /* domain model */ }
   
   // internal/clients/<service>/models.go - Infrastructure DTOs
   type Agent struct { /* ✅ Infrastructure DTO */ }
   ```

5. **God Interface Anti-Pattern** 🚨
   ```go
   // ❌ BAD: God Interface - 25+ methods, violates ISP
   type Repository interface {
       CreateSaying(...)
       GetSayingByID(...)
       UpdateSaying(...)
       DeleteSaying(...)
       CreateTranslation(...)
       GetTranslationByID(...)
       // ... 20+ more methods
   }
   // → TranslationService forced to depend on Saying/Evaluation methods!
   
   // ✅ GOOD: Segregated interfaces - focused and small
   type SayingRepository interface {
       Create(ctx context.Context, saying *Saying) error
       GetByID(ctx context.Context, id uuid.UUID) (*Saying, error)
       Update(ctx context.Context, saying *Saying) error
       Delete(ctx context.Context, id uuid.UUID) error
   }
   
   type TranslationRepository interface {
       Create(ctx context.Context, translation *Translation) error
       GetByID(ctx context.Context, id uuid.UUID) (*Translation, error)
       Update(ctx context.Context, translation *Translation) error
       Delete(ctx context.Context, id uuid.UUID) error
   }
   ```

6. **Error Not Wrapped**
   ```go
   // ❌ BAD: Generic error
   if err != nil {
       return err
   }
   
   // ✅ GOOD: Domain error
   if err != nil {
       return errors.NewDomainError(
           errors.ErrExternalAPI,
           "Failed to create agent",
           err,
       )
   }
   ```

7. **fmt.Print Instead of Logger** 🚨 CRITICAL
   ```go
   // ❌ BAD: fmt.Print bypasses structured logging
   fmt.Printf("Saying created: %s\n", saying.ID)
   fmt.Println("Processing complete")
   if err != nil {
       fmt.Printf("Error: %v\n", err)  // ← BAD PRACTICE!
   }
   
   // ✅ GOOD: Use logger for all output
   logger.WithField("saying_id", saying.ID).Info("Saying created successfully")
   logger.Info("Processing complete")
   if err != nil {
       logger.WithError(err).Error("Failed to process saying")
   }
   ```

8. **Silent Error Handling - State Persistence** 🚨 CRITICAL
   ```go
   // ❌ BAD: State persistence error silently ignored - CAUSES INFINITE LOOPS
   if err := contextService.AddTranslationVersion(ctx, evalContext, version, ...); err != nil {
       logger.Error(err)  // BAD PRACTICE: State is now inconsistent!
       // Continue as if nothing happened
   }
   
   // ✅ GOOD: Return error when state persistence fails
   if err := contextService.AddTranslationVersion(ctx, evalContext, version, ...); err != nil {
       logger.WithError(err).Error("Failed to persist evaluation results")
       return errors.NewDomainError(
           errors.ErrExternalAPI,
           "Evaluation succeeded but failed to persist results - context state is inconsistent",
           err,
       )
   }
   ```

9. **Silent Error Handling - Session Refresh** 🚨 CRITICAL
   ```go
   // ❌ BAD: Session refresh error silently ignored - CAUSES STALE STATE
   updatedContext, err := contextService.GetEvaluationContext(ctx, sayingID)
   if err == nil && updatedContext != nil {
       // Update session...
   }
   // Error silently ignored - BAD PRACTICE: Session state is stale!
   
   // ✅ GOOD: Return error when session refresh fails
   updatedContext, err := contextService.GetEvaluationContext(ctx, sayingID)
   if err != nil {
       logger.WithError(err).Error("Failed to refresh session state")
       return errors.NewDomainError(
           errors.ErrExternalAPI,
           "Failed to refresh session state - session state is stale and unreliable",
           err,
       )
   }
   if updatedContext == nil {
       return errors.NewDomainError(
           errors.ErrExternalAPI,
           "Session refresh returned nil - session state is unreliable",
           nil,
       )
   }
   ```

10. **HTTP Response Body Not Closed**
   ```go
   // ❌ BAD: Resource leak
   resp, err := c.doRequest(ctx, "GET", endpoint, nil)
   json.NewDecoder(resp.Body).Decode(&result)
   
   // ✅ GOOD: Always close
   resp, err := c.doRequest(ctx, "GET", endpoint, nil)
   if err != nil {
       return err
   }
   defer resp.Body.Close()
   json.NewDecoder(resp.Body).Decode(&result)
   ```

11. **Over-Exporting / Internal Details Exposed** 🚨
   ```go
   // ❌ BAD: Internal implementation exported
   type Orchestrator struct {  // Should be 'orchestrator' (lowercase)
       evaluationClient dspy.EvaluationClient
   }
   
   func (o *Orchestrator) EvaluateTranslation(...) {  // Should be 'evaluateTranslation'
       // Only used internally
   }
   
   // ✅ GOOD: Only public API exported
   type ServiceInterface interface {  // ✅ Public API
       EvaluateTranslationResult(...)
   }
   
   func NewService(...) ServiceInterface {  // ✅ Constructor
       // ...
   }
   
   type orchestrator struct {  // ✅ Internal struct private
       evaluationClient dspy.EvaluationClient
   }
   
   func (o *orchestrator) evaluateTranslation(...) {  // ✅ Internal method private
       // ...
   }
   ```
   **Detection**:
   - Check if internal structs/interfaces/methods are exported (uppercase)
   - Verify they're only used within the package
   - **Rule**: Export only public API interfaces and constructors
   - **Verification**: `grep -r "^type [A-Z]" package/` → Check usage outside package

---

**Remember**: The goal isn't to criticize the code, but to ensure it works correctly and efficiently. Finding bugs early is being THOROUGH and PROFESSIONAL, not being negative.
