# LuaBot Documentation Generation Plan

## Overview
Implement a documentation generator (`util/docs.py`) that extracts documentation from C++ headers and YAML binding definitions, then generates:
1. LuaLS-compatible annotations in generated Lua modules for IDE code completion
2. Standalone Markdown documentation for the API reference

## Goals
- Provide rich code completion in VS Code and other Lua LSP-enabled editors
- Generate comprehensive API documentation from the source of truth (C++ headers)
- Handle edge cases where C++ documentation is missing or incomplete
- Maintain consistency between generated code and documentation

## Architecture

### Input Sources
1. **C++ Headers** (primary source)
   - Parse Doxygen-style comments (`/** ... */`, `///`)
   - Extract class descriptions, method documentation
   - Parse tags: `@brief`, `@param`, `@return`, `@see`, `@note`
   - Location: `deps/allwpilib/` subdirectories

2. **YAML Binding Definitions** (secondary source)
   - Read from `bindings/wpi/**/*.yaml`
   - Optional `doc:` field for method-level documentation
   - Optional `doc:` field at class level for class description
   - Maps C++ APIs to exposed Lua APIs

3. **Heuristics** (fallback source)
   - Detect operator overloads in `c_body` field
   - Generate basic documentation from method signatures
   - Provide sensible defaults for common patterns

### Output Formats

#### 1. LuaLS Annotations in Generated Lua Files
Location: `build/lua/wpi/**/*.lua`

```lua
---@class frc.AprilTag
---Represents an AprilTag fiducial marker for vision processing.
---AprilTags are used for robot localization and object detection.
---
---@see https://docs.wpilib.org/en/stable/docs/software/vision-processing/apriltag/
local AprilTag = {}

---Creates a new AprilTag instance.
---
---@return frc.AprilTag # A new AprilTag object
function AprilTag.new()
    return ffi.gc(C.frcAprilTagNew(), C.frcAprilTagDelete)
end

---Compares this AprilTag with another for equality.
---Checks if both tags have the same ID and pose.
---
---@param other frc.AprilTag # The tag to compare against
---@return boolean # True if the tags are equal
function AprilTag:equals(other)
    return C.frcAprilTagEquals(self, other)
end

return AprilTag
```

**Annotation Format:**
- `---@class Namespace.ClassName` - Class definition
- `---@param name type # description` - Parameter documentation
- `---@return type # description` - Return value documentation
- `---@see url` - Links to additional documentation
- `---@field name type # description` - For class fields/properties
- Multi-line descriptions separated by blank comment lines

#### 2. Markdown API Documentation
Location: `docs/api/wpi/**/*.md`

```markdown
# wpi.apriltag.AprilTag

Represents an AprilTag fiducial marker for vision processing.
AprilTags are used for robot localization and object detection.

**C++ Header:** `frc/apriltag/AprilTag.h`  
**Namespace:** `frc`

## Constructor

### AprilTag.new()

Creates a new AprilTag instance.

**Returns:** `AprilTag` - A new AprilTag object

**Example:**
```lua
local AprilTag = require('wpi.apriltag.AprilTag')
local tag = AprilTag.new()
```

## Methods

### tag:equals(other)

Compares this AprilTag with another for equality.
Checks if both tags have the same ID and pose.

**Parameters:**
- `other` (`AprilTag`) - The tag to compare against

**Returns:** `boolean` - True if the tags are equal

**Example:**
```lua
local tag1 = AprilTag.new()
local tag2 = AprilTag.new()
if tag1:equals(tag2) then
    print("Tags are equal")
end
```

## See Also
- [WPILib AprilTag Documentation](https://docs.wpilib.org/en/stable/docs/software/vision-processing/apriltag/)
```

### Documentation Extraction Strategy

#### Priority Levels (Highest to Lowest)

##### Level 1: C++ Header Doxygen Comments
**Source:** Parse header file specified in `header:` field of YAML

**Parsing Strategy:**
```python
class DoxygenParser:
    def parse_class_comment(self, header_path: str, class_name: str) -> Optional[ClassDoc]:
        """Extract /** ... */ comment block preceding class declaration"""
        
    def parse_method_comment(self, header_path: str, method_name: str) -> Optional[MethodDoc]:
        """Extract comment block preceding method declaration"""
        
    def parse_tags(self, comment: str) -> dict:
        """Extract @brief, @param, @return, @see tags"""
```

**Challenges:**
- C++ preprocessing (macros, includes)
- Template specializations
- Operator overloads may not have direct comments
- Method overloads (need to match signature)

**Solution:**
- Use simple regex-based parser (avoid full C++ parser complexity)
- Match comment blocks immediately preceding declarations
- For operators, look for comments on the operator declaration
- Handle multi-line comments and tag continuations

##### Level 2: YAML Documentation Fields
**Source:** Optional `doc:` fields in YAML definitions

**Format:**
```yaml
typename: AprilTag
doc: |
  Represents an AprilTag fiducial marker for vision processing.
  AprilTags are used for robot localization and object detection.

methods:
  Equals:
    const: true
    return_type: bool
    params:
      other: const-cptr
    c_body: return (*(const frc::AprilTag*) self) == (*(const frc::AprilTag*) other);
    doc: |
      Compares this AprilTag with another for equality.
      Checks if both tags have the same ID and pose.
    params_doc:
      other: The tag to compare against
    return_doc: True if the tags are equal
```

**Fields:**
- `doc:` - Main description (class or method level)
- `params_doc:` - Dictionary mapping parameter names to descriptions
- `return_doc:` - Return value description
- `see:` - List of URLs or cross-references
- `example:` - Lua code example

##### Level 3: Operator Heuristics
**Source:** Detect operator patterns in `c_body` field

**Mapping Table:**
```python
OPERATOR_DOCS = {
    'operator==': {
        'brief': 'Compares for equality',
        'return': 'True if equal',
        'template': 'Checks if this {typename} equals another {typename}.'
    },
    'operator!=': {
        'brief': 'Compares for inequality',
        'return': 'True if not equal',
        'template': 'Checks if this {typename} differs from another {typename}.'
    },
    'operator<': {
        'brief': 'Less than comparison',
        'return': 'True if less than',
        'template': 'Checks if this {typename} is less than another {typename}.'
    },
    'operator+': {
        'brief': 'Addition',
        'return': 'Sum of operands',
        'template': 'Adds two {typename} objects.'
    },
    # ... more operators
}
```

**Detection:**
```python
def detect_operator(c_body: str) -> Optional[str]:
    """Parse c_body for operator usage"""
    # Match patterns like: return *self == *other;
    # Extract: operator==
```

##### Level 4: Signature-Based Generation
**Source:** Method name, parameters, return type from YAML

**Generation Rules:**
```python
def generate_fallback_doc(typename: str, method_name: str, config: dict) -> MethodDoc:
    params_desc = []
    for param_name, param_type in config.get('params', {}).items():
        lua_type = map_cpp_type_to_lua(param_type)
        params_desc.append(f"- `{param_name}` (`{lua_type}`)")
    
    return_type = map_cpp_type_to_lua(config['return_type'])
    
    doc = MethodDoc(
        brief=f"{method_name} method",
        params=params_desc,
        returns=f"`{return_type}`"
    )
    return doc
```

##### Level 5: Minimal Placeholder
**Source:** Generate minimal valid documentation

```lua
---TODO: Add documentation for this method
---@param other frc.AprilTag
---@return boolean
function AprilTag:equals(other)
```

### Type Mapping (C++ → Lua)

```python
CPP_TO_LUA_TYPES = {
    # Primitives
    'bool': 'boolean',
    'int': 'integer',
    'int8_t': 'integer',
    'int16_t': 'integer',
    'int32_t': 'integer',
    'int64_t': 'integer',
    'uint8_t': 'integer',
    'uint16_t': 'integer',
    'uint32_t': 'integer',
    'uint64_t': 'integer',
    'float': 'number',
    'double': 'number',
    'size_t': 'integer',
    
    # Strings
    'std::string': 'string',
    'std::string_view': 'string',
    'const char*': 'string',
    'char*': 'string',
    
    # Special
    'void': 'nil',
    'cptr': None,  # Use typename from context
    'const-cptr': None,  # Use typename from context
}

def map_cpp_type_to_lua(cpp_type: str, typename: str = None) -> str:
    """Map C++ type to Lua type for annotations"""
    # Strip const, &, *
    base_type = cpp_type.replace('const', '').replace('&', '').replace('*', '').strip()
    
    # Check primitive mapping
    if base_type in CPP_TO_LUA_TYPES:
        result = CPP_TO_LUA_TYPES[base_type]
        return result if result else typename
    
    # Handle pointers (likely class types)
    if '*' in cpp_type or 'cptr' in cpp_type:
        return typename or 'userdata'
    
    # Assume it's a class name
    return base_type
```

### Integration with parse.py

```python
# util/parse.py

from docs import DocumentationGenerator

def generate_bindings(yaml_files: list[str], output_dir: str):
    doc_gen = DocumentationGenerator(
        wpilib_path='deps/allwpilib',
        fallback_operators=True
    )
    
    for yaml_file in yaml_files:
        config = load_yaml(yaml_file)
        
        # Extract documentation
        class_docs = doc_gen.extract_class_docs(
            header=config['header'],
            typename=config['typename'],
            namespace=config['namespace'],
            yaml_config=config
        )
        
        # Generate Lua module with annotations
        lua_code = generate_lua_module(config, class_docs)
        write_file(f"{output_dir}/lua/{lua_code.path}", lua_code.content)
        
        # Generate Markdown documentation
        markdown = doc_gen.generate_markdown(config, class_docs)
        write_file(f"docs/api/{markdown.path}", markdown.content)
        
        # Generate C++ FFI declarations
        cpp_code = generate_cpp_ffi(config)
        write_file(f"{output_dir}/include/{cpp_code.path}", cpp_code.content)
```

## Implementation Phases

### Phase 1: Core Infrastructure
**Goal:** Basic documentation extraction and generation

**Tasks:**
1. Create `util/docs.py` module structure
2. Implement simple Doxygen comment parser (regex-based)
3. Implement type mapping (C++ → Lua)
4. Create data structures for storing extracted docs
5. Write unit tests for parser

**Deliverables:**
- `util/docs.py` with `DoxygenParser` class
- `util/test_docs.py` with parser tests
- Type mapping dictionary and function

### Phase 2: LuaLS Annotation Generation
**Goal:** Generate annotations in Lua modules

**Tasks:**
1. Implement `LuaLSFormatter` class
2. Format class annotations (`---@class`)
3. Format method annotations (`---@param`, `---@return`)
4. Handle multi-line descriptions
5. Integrate with existing Lua code generation in `parse.py`

**Deliverables:**
- Updated `generate_lua_module()` to include annotations
- Regenerate all Lua modules with annotations
- Test code completion in VS Code

### Phase 3: Fallback Documentation
**Goal:** Handle missing documentation gracefully

**Tasks:**
1. Implement YAML `doc:` field parsing
2. Implement operator detection and mapping
3. Implement signature-based fallback generation
4. Create priority system for selecting documentation source
5. Add warnings for missing documentation

**Deliverables:**
- Complete fallback chain implementation
- Warning system for undocumented methods
- Updated `AprilTag.yaml` with `doc:` fields as example

### Phase 4: Markdown Generation
**Goal:** Generate standalone API documentation

**Tasks:**
1. Implement `MarkdownFormatter` class
2. Generate per-class Markdown files
3. Create index/navigation structure
4. Add usage examples
5. Cross-reference between classes

**Deliverables:**
- `docs/api/` directory with generated Markdown
- `docs/api/index.md` with class listing
- Example usage snippets in documentation

### Phase 5: Polish and Validation
**Goal:** Ensure quality and completeness

**Tasks:**
1. Validate all generated annotations with LuaLS
2. Check documentation coverage (% of methods documented)
3. Add CMake target for doc generation
4. Update developer documentation
5. Generate docs for all existing bindings

**Deliverables:**
- CMake target: `ninja docs`
- Coverage report showing documentation completeness
- Updated `.github/copilot-instructions.md`
- Complete API documentation for all WPILib bindings

## File Structure

```
luabot/
├── util/
│   ├── docs.py              # Main documentation generator
│   ├── test_docs.py         # Unit tests
│   └── parse.py             # Updated with doc integration
├── docs/
│   ├── api/
│   │   ├── index.md         # API reference home
│   │   └── wpi/
│   │       ├── frc/
│   │       │   ├── TimedRobot.md
│   │       │   └── ...
│   │       ├── apriltag/
│   │       │   └── AprilTag.md
│   │       └── ...
│   └── examples/            # Usage examples
├── bindings/
│   └── wpi/
│       └── apriltag/
│           └── AprilTag.yaml  # Enhanced with doc: fields
└── build/
    └── lua/
        └── wpi/
            └── apriltag/
                └── AprilTag.lua  # Generated with annotations
```

## Testing Strategy

### Unit Tests
```python
# util/test_docs.py

def test_parse_doxygen_brief():
    """Test extraction of @brief tag"""
    
def test_parse_doxygen_params():
    """Test extraction of @param tags"""
    
def test_parse_doxygen_return():
    """Test extraction of @return tag"""
    
def test_detect_operator_equals():
    """Test detection of operator== in c_body"""
    
def test_cpp_to_lua_type_mapping():
    """Test type conversion"""
    
def test_luals_annotation_format():
    """Test LuaLS annotation generation"""
```

### Integration Tests
1. Generate docs for `AprilTag` class
2. Verify LuaLS recognizes annotations in VS Code
3. Check Markdown renders correctly
4. Validate cross-references work
5. Test fallback chain with missing C++ docs

### Quality Metrics
- **Coverage:** % of methods with documentation
- **Source breakdown:** % from headers vs fallbacks
- **Completeness:** All @param and @return fields filled
- **Validation:** LuaLS has no annotation errors

## Future Enhancements

### Phase 6: Advanced Features
- Generate documentation for properties/fields
- Support for enums and constants
- Generate UML class diagrams
- Interactive documentation site (MkDocs/Docusaurus)
- Search functionality
- Version tracking (document breaking changes)

### Phase 7: Developer Tools
- VS Code extension for inline doc preview
- Doc comment linter for YAML files
- Auto-generate YAML `doc:` fields from headers
- Documentation coverage badge
- CI/CD integration (fail on missing docs)

## Open Questions

1. **Overloaded Methods:** How to document when C++ has multiple overloads but Lua has one?
   - **Proposal:** Document all overloads, note which parameters are optional

2. **Templates:** How to document templated classes?
   - **Proposal:** Document concrete instantiations only (e.g., `Pose2d`, not `Pose<2>`)

3. **Inheritance:** Should Lua docs show inherited methods?
   - **Proposal:** Yes, with note about which class they're inherited from

4. **Static Methods:** How to distinguish in Lua?
   - **Proposal:** Use `ClassName.method()` vs `instance:method()` notation

5. **Example Code:** Where to source examples from?
   - **Proposal:** Add `example:` field to YAML, or reference `util/robots/` examples

## Success Criteria

- [ ] All generated Lua modules have LuaLS annotations
- [ ] VS Code provides code completion for all WPILib APIs
- [ ] Markdown documentation covers 100% of exposed APIs
- [ ] Documentation build integrated into CMake workflow
- [ ] Coverage report shows >90% documentation from C++ headers
- [ ] Zero LuaLS annotation errors
- [ ] Developer documentation updated with doc generation workflow

## Notes

- Keep parser simple - avoid full C++ parsing complexity
- Prioritize correctness over completeness initially
- Focus on WPILib classes first, expand to HAL later
- Consider using `libclang` for Phase 6 if regex parser insufficient
- Ensure generated docs are version-controlled in `docs/api/`