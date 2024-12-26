
本标准中定义的操作列表如下：    
* [read](#read) 读取资源的当前内容  
* [vread](#vread) 读取特定版本资源的状态  
* [update](#update) 根据ID更新已有资源（如果没有，则创建它）    
* [delete](#delete) 删除某个资源 
* [validate](#validate) 验证资源的合规性    
* [create](#create) 使用服务器分配的ID创建新资源   
* [history](#history) 检索特定资源的更改历史记录  
* [search](#search) 根据某些筛选条件搜索资源类型 

## API基础

### 格式指南 
本页介绍的交互使用格式如下：  
``` 
  VERB [基地址]/[资源类型]/[逻辑id] {?_format=[mime-type]}
```
VERB就是FHIR支持的几种HTTP方法，如GET/POST/PUT等    
方括号中的内容（“基地址”、“资源类型”）是必填项，在实际使用中方括号中的内容可以有以下几种：    
基地址(base)：服务端提供服务的根URL地址  
资源类型(type)：资源的名称，如Organization，Patient等  
逻辑id(id)：资源实例的id，对于针对资源类型（如create）而不是实例的操作不需要。 
_format: 资源的表达格式。交互接口本身支持XML与JSON两种表达形态，相应地则需维护两套格式标准。因此，在本次发布的版本中，只采用JSON格式的表达。XML格式的表达方式将随标准版本的迭代和应用效果决定是否开放。 

### 服务基地址（Base URL） 
服务基地址（Base URL）是一个API接口地址，接口中定义的所有资源都可以在这个地址里找到。  
服务基地址格式如下：  
``` 
http{s}://server{/path}
``` 
path部分是可选项，path后面没有斜线，每一种resource类型都有一个起点(或者叫实体集)，在path之后添加/[type]， 这个 [type]是resource的类型。举例来说，对Organization资源来说，就是这样的：   
``` 
https://server/path/Organization
``` 
所有与组织机构相关的业务交互的URL对于根URL来说都是相对的。这就意味着所有资源在整个系统都是可知的， 其他的资源基本上也是可以以此类推。  
注意：所有规范定义的URL(所有组成URL部分的id)都是大小写敏感的。 客户端应该用utf-8对所有URL进行编码，服务端应该用UTF-8进行解码。  

### 资源元数据和版本控制
每个资源都有一组关联的资源元数据元素。这些映射到HTTP请求和响应，使用以下字段：    
* [Version Id](https://hl7.org/fhir/R4/resource.html#Meta) 资源实例的版本号    
* [lastUpdated](https://hl7.org/fhir/R4/resource.html#Meta) 最后更新时间    
* [profile](https://hl7.org/fhir/R4/resource.html#Meta) 声明资源实例符合资源规范（StructureDefinition）的断言    
特别应当注意profile元素。由于本标准支持同时部署多个资源规范，例如通过同一个API接口，也可以让Organization资源分别支持0.1.0和1.0.0版本的资源定义。  
因此，当使用POST、PUT等将改变资源实例内容的接口时，该元数据条目必需提供，以便验证数据的质量。  
以下为元数据条目的表述形式。  
``` json
{
"meta": {
        "profile": [
            "http://example.org/StructureDefinition/hc-mdm-organization|0.1.0"
        ],
        "lastUpdated": "2024-11-10T14:01:08Z",
        "versionId": "1"
    }
}
``` 

### HTTP状态码
本标准将使用 [OperationOutcome](https://hl7.org/fhir/R4/operationoutcome.html) 资源封装响应，可用于传递特定的可处理的详细错误信息或说明。  
对于某些交互组合和特定的返回代码，需要返回 OperationOutcome 作为响应内容。  
OperationOutcome 可以与任何 HTTP 4xx 或 5xx 响应一起返回，但这并不是必须的，因为许多此类错误可能是由服务器底层的通用服务器框架生成的。

### Content Types 与 编码
资源的正式MIME类型是 application/fhir+json 。
客户端和服务器交互时必须使用正确的 MIME 类型。


## read 
[详细解释](https://hl7.org/fhir/R4/http.html#read)    
读取交互可访问资源的当前内容。交互由 HTTP GET 命令执行，如图所示：
```
  GET [base]/[type]/[id] {?_format=[mime-type]}
```
这将返回一个包含为资源类型指定的内容的单一实例。浏览器可以访问该 URL。逻辑标识符（“id”）本身的可能值在 id 类型中描述。返回的资源必须有一个 id 元素，其值为 [id]。服务器应返回包含资源版本 ID 的 ETag 标头（如果支持版本控制）和 Last-Modified 标头。  
注意：未知资源和已删除资源在读取时的处理方式不同：对已删除资源的 GET 会返回 410 状态代码，而对未知资源的 GET 会返回 404。不跟踪已删除记录的系统会将已删除记录视为未知资源。由于已删除的资源可能会被激活，因此在读取已删除记录时，服务器可能会在错误响应中包含一个 ETag，以便在资源复活时进行版本争用管理。

## vread 
[详细解释](https://hl7.org/fhir/R4/http.html#vread)    
vread 交互对资源执行特定版本的读取。交互由 HTTP GET 命令执行，如图所示：
```
  GET [base]/[type]/[id]/_history/[vid] {?_format=[mime-type]}
```
这将返回一个单一实例，其中包含为该版本资源的资源类型指定的内容。返回的资源应包含一个值为 [id] 的 id 元素和一个值为 [vid] 的 meta.versionId 元素。服务器应返回带有版本 ID 的 ETag 标头（如果支持版本控制）和 Last-Modified 标头。  
版本标识符（“vid”）是一种标识符，符合与逻辑标识符相同的格式要求。版本标识可能是通过执行历史交互（见下文）、从读取返回的内容位置记录版本标识或从内容模型中的特定版本引用中找到的。如果所引用的版本实际上是资源被删除的版本，服务器应返回 410 状态代码。  
我们鼓励服务器即使不提供对以前版本的访问，也要支持对资源当前版本的特定版本检索。如果请求的是资源的以前版本，而服务器不支持访问以前的版本（无论是一般版本还是此特定资源的版本），则应返回 404 Not Found 错误，并在操作结果中说明不支持基础资源类型或实例的历史记录。

## update 
[详细解释](https://hl7.org/fhir/R4/http.html#update)   
更新交互可为现有资源创建一个新的当前版本，如果给定 id 下不存在资源，则创建一个初始版本。更新交互由 HTTP PUT 命令执行，如图所示：
```
  PUT [base]/[type]/[id] {?_format=[mime-type]}
```
必须在一个request body中包含一个**完整**的资源实例，其 id 元素的值与 URL 中的 [id] 相同。如果没有提供 id 元素，或者 id 与 URL 中的 id 不一致，服务器将响应 HTTP 400 错误代码，并应提供一个 OperationOutcome 来标识问题。如果请求体包含meta元素，服务器将忽略提供的 versionId 和 lastUpdated 值。如果服务器支持版本，则应使用新的正确值填充 meta.versionId 和 meta.lastUpdated。目前还不支持更新过去的版本。  
如果交互成功，服务器将返回 200 OK HTTP 状态代码（如果资源已更新），或 201 创建状态代码（如果资源已创建（或重新激活/重新创建）），并返回 Last-Modified 标头和包含资源新版本 ID 的 ETag 标头。如果资源已创建（即交互的结果是 201 Created），服务器就应返回一个 Location 头信息（这是为了符合 HTTP 协议；在其他情况下并不需要）。

## delete
[详细解释](https://hl7.org/fhir/R4/http.html#delete)   
删除交互可删除现有资源。交互由 HTTP DELETE 命令执行，如图所示：
```
  DELETE [base]/[type]/[id]
```
请求的equest body应为空。    
删除交互意味着对资源的后续非特定版本读取将返回 410 HTTP 状态代码，并且通过搜索交互不再能找到该资源。删除成功后，或者如果资源根本不存在，如果响应包含有效载荷，服务器应返回 200 OK；如果没有响应有效载荷，则返回 204 No Content；如果服务器希望对删除结果不做任何承诺，则返回 202 Accepted。
许多资源都有一个与删除概念重叠的status元素。每种资源类型都定义了删除交互的语义。如果没有提供相关文档，删除交互应被理解为删除资源记录，而不涉及现实世界中相应资源的状态。对status元素的操作应通过update等可更新资源的操作实现。  

## validate
[详细解释](https://hl7.org/fhir/R4/resource-operation-validate.html)   
验证检查附加的内容是否满足标准要求，是否可被服务器接受，用于创建、更新或删除现有资源。  
```
POST [base]/[Resource]/$validate?profile=[profile|version]
```
其中[profile|version]参数用于指定要验证的资源应遵循的profile及其版本。在本标准中，要验证组织机构主数据的合规性，profile应取值为 http://[标准发布地址]/StructureDefinition/hc-mdm-organization|0.1.0 。不指定profile参数将导致服务器无法确定使用哪一个特定规范验证其合规性，只能验证其是否符合FHIR的基本格式。   
此操作的返回值是 [OperationOutcome](https://hl7.org/fhir/R4/operationoutcome.html)。  
此操作可用于设计和开发期间，以验证应用程序设计。它也可以在运行时使用。一种可能的用途是，当用户正在编辑对话框时，客户端询问服务器建议的更新是否有效，并向用户显示更新的错误。该操作可以用作轻量级两阶段提交协议的一部分，但并不期望服务器在使用此操作后保留资源的内容，或者服务器保证在验证操作完成后成功执行实际的创建、更新或删除。  
无论资源是否有效，此操作都将返回 200 OK。4xx 或 5xx 错误意味着无法执行验证本身，并且不知道资源是否有效。  
### 验证示例

#### 包含完整规范执行验证
请求：使用 POST 根据组织机构主数据标准验证组织机构。
```
POST /[FHIR服务器地址]/Organization/$validate?profile=http://example.org/StructureDefinition/hc-mdm-organization|0.1.0

Content-Type=application/fhir+json
```
被验证资源如下：  
``` json
{
    "resourceType": "Organization",
    "meta": {
        "profile": [
            "http://example.org/StructureDefinition/hc-mdm-organization|0.1.0"
        ]
    },
    "extension": [
        {
            "url": "http://example.org/StructureDefinition/hc-mdm-administrativedivision",
            "valueCoding": {
                "system": "http://example.org/CodeSystem/cq-administrativedivision-code-system",
                "code": "500112",
                "display": "渝北区"
            }
        }
    ],
    "identifier": [
        {
            "use": "official",
            "type": {
                "coding": [
                    {
                        "system": "http://example.org/CodeSystem/identifierType-code-system",
                        "code": "USCC",
                        "display": "统一社会信用代码"
                    }
                ]
            },
            "value": "11500000MB1670604%"
        }
    ],
    "active": true,
    "type": [
        {
            "coding": [
                {
                    "system": "http://example.org/CodeSystem/organizationtype-code-system",
                    "code": "121",
                    "display": "事业单位法人"
                }
            ]
        }
    ],
    "name": "重庆市卫生健康委员会"
}
```
经验证后可见OperationOutcome内容如下：
``` json
{
    "resourceType": "OperationOutcome",
    "issue": [
        {
            "severity": "error",
            "code": "invariant",
            "details": {
                "text": "generated-hc-mdm-organization-2: Constraint violation: identifier.where(type.where(coding.where(system = 'http://example.org/CodeSystem/identifierType-code-system' and code = 'USCC').exists())).exists() implies (identifier.where(type.where(coding.where(system = 'http://example.org/CodeSystem/identifierType-code-system' and code = 'USCC').exists())).count() = 1 and identifier.where(type.where(coding.where(system = 'http://example.org/CodeSystem/identifierType-code-system' and code = 'USCC').exists())).all((use.exists() implies (use = 'official')) and type.where(coding.where(system = 'http://example.org/CodeSystem/identifierType-code-system' and code = 'USCC').exists()).exists() and (value.matches('^[159Y]{1}[1239]{1}[0-9]{6}[0-9A-Z]{9}[0-9A-Z*]{1}$'))))"
            },
            "diagnostics": "Caused by: [[expression: value.matches('^[159Y]{1}[1239]{1}[0-9]{6}[0-9A-Z]{9}[0-9A-Z*]{1}$'), result: false, location: Organization.identifier[0]]]",
            "expression": [
                "Organization"
            ]
        },
        {
            "severity": "warning",
            "code": "invariant",
            "details": {
                "text": "dom-6: A resource should have narrative for robust management"
            },
            "expression": [
                "Organization"
            ]
        },
        {
            "severity": "information",
            "code": "code-invalid",
            "details": {
                "text": "identifier-0: A code in this element must be from the specified value set 'http://hl7.org/fhir/ValueSet/identifier-type' if possible"
            },
            "expression": [
                "Organization.identifier[0].type"
            ]
        }
    ]
}
``` 
可见其中由于统一社会信用代码未通过格式验证产生的error级错误。其中也包括warning和information级错误，用户可自行选择是否需要处理。

#### 不指定规范执行验证
如采用同样的资源内容，但不指定验证所需的profile
请求：使用 POST 根据组织机构主数据标准验证组织机构。
```
POST /[FHIR服务器地址]/Organization/$validate

Content-Type=application/fhir+json
```
则服务器将忽略验证，直接返回成功。
``` json
{
    "resourceType": "OperationOutcome",
    "issue": [
        {
            "severity": "information",
            "code": "informational",
            "diagnostics": "All OK",
            "details": {
                "text": "All OK"
            }
        }
    ]
}
``` 



## create 
[详细解释](https://hl7.org/fhir/R4/http.html#create)   
创建交互会在服务器指定的位置创建一个新资源。如果客户端希望控制新提交资源的 id，则应使用update交互。创建交互由 HTTP POST 命令执行，如图所示：
```
  POST [base]/[type] {?_format=[mime-type]}
```
请求体必须是 FHIR 资源。该资源不需要有 id 元素（这是为数不多的没有 id 元素的资源）。如果提供了 id，服务器将忽略它。如果请求体包含元，服务器将忽略现有的 versionId 和 lastUpdated 值。服务器应使用新的正确值填充 id、meta.versionId 和 meta.lastUpdated。  
服务器返回一个 201 Created 的 HTTP 状态代码，还必须返回一个 Location 头信息，其中包含创建的资源版本的新逻辑标识和版本标识：  
```
  Location: [base]/[type]/[id]/_history/[vid]
```
其中，[id] 和 [vid] 是新创建的资源版本 id 和版本 id。位置标头应尽可能具体--如果服务器了解版本控制，就会包含版本。如果服务器不跟踪版本，Location 头将只包含 [base]/[type]/[id] 。位置可以是绝对或相对 URL。  
当资源语法或数据不正确或无效，无法用于创建新资源时，服务器会返回 400 Bad Request HTTP 状态代码。当服务器因业务规则而拒绝接受资源内容时，服务器会返回 422 不可处理实体错误 HTTP 状态代码。无论是哪种情况，服务器都应该包含一个响应体，其中包含一个 OperationOutcome，并附有详细的错误信息，说明错误的原因。  
与 FHIR 相关的错误返回的常见 HTTP 状态代码（除与安全、标头和内容类型协商问题相关的正常 HTTP 错误外）：  
* 400 Bad Request - 资源无法解析或未能通过基本的 FHIR 验证规则  
* 404 Not Found - 资源类型不受支持，或不是 FHIR 端点
* 422 Unprocessable Entity - 建议的资源违反了适用的 FHIR 配置文件或服务器业务规则。应随附一个 OperationOutcome 资源，提供更多细节。  
一般来说，如果实例不符合约束条件，则响应应为 400，而如果实例不符合其他非外部描述的业务规则，则响应应为 422 错误。不过，服务器在这些情况下也可以返回 5xx 错误，而不会被视为不符合要求。 

## history
[详细解释](https://hl7.org/fhir/R4/http.html#history)    
历史交互可检索特定资源、给定类型的所有资源或系统支持的所有资源的历史。如图所示，历史交互的这三种变化都是通过 HTTP GET 命令执行的：
```
  GET [base]/[type]/[id]/_history{?[parameters]&_format=[mime-type]}
  GET [base]/[type]/_history{?[parameters]&_format=[mime-type]}
  GET [base]/_history{?[parameters]&_format=[mime-type]}
```
返回内容是一个类型设为历史记录的数据包，包含指定的历史版本，按最旧版本排序， 最后一个版本包括已删除的资源。每个条目至少应包含以下内容之一：在交互结束时保存资源的资源，或带有 entry.request.method 的请求。该请求提供有关导致产生新版本的交互结果的信息，并允许用户系统区分新创建的资源和对现有资源的更新。资源丢失的主要原因是资源是通过其他渠道而不是 RESTful 接口更改的。如果 entry.request.method 是 PUT 或 POST，则条目应包含一个资源。  
交互create, update, 和 delete会创建历史条目。其他交互则不会（请注意，这些操作可能会产生副作用，例如产生新的审计事件资源；这些资源本身就表示为创建交互）。由操作触发的新资源或对现有资源的更新也会出现在历史记录中。


## search
[详细解释](https://hl7.org/fhir/R4/http.html#search)   
这种交互方式会根据一些筛选条件搜索一组资源。该交互可通过几种不同的 HTTP 命令来执行。
```
  GET [base]/[type]{?[parameters]{&_format=[mime-type]}}
```
这将使用参数中表示的标准搜索特定类型的所有资源。  
如果搜索成功，服务器将返回一个 200 OK HTTP 状态代码，返回的内容将是一个类型为 searchset 的[Bundle](https://hl7.org/fhir/R4/bundle.html)资源，其中包含按定义顺序排列的零个或多个资源的搜索结果集合。请注意，搜索Bundle包中返回的资源可能位于执行搜索的服务器之外的另一个服务器上（即 Bundle.entry.fullUrl 可能不同于搜索 URL 中的 [base]）。  
结果集合可能很长，因此服务器可能会使用分页。如果使用分页，则应使用下面描述的方法（改编自 RFC 5005（Feed Paging and Archiving）），在适当的情况下将结果集合分成几页。服务器还可以在搜索集束条目中返回 OperationOutcome 资源，该资源包含有关搜索的附加信息；如果发送了 OperationOutcome 资源，它不得包含任何致命或错误严重程度的问题，并且必须标记为 Bundle.entry.search.mode of outcome。  
如果搜索失败（无法执行，而不是没有匹配结果），返回值应为状态代码 4xx 或 5xx，并带有 OperationOutcome。  
相关的错误返回的常见 HTTP 状态代码（除与安全、标头和内容类型协商问题相关的正常 HTTP 错误外）：
* 400 Bad Request - 搜索无法处理或未能通过基本的验证规则
* 401 Not Authorized - 尝试的交互需要授权
* 404 Not Found - 资源类型不受支持，或不是有效端点  

各类不同资源支持的参数各不相同，可通过查询该资源的定义获取详情。例如，[Organization资源的查询参数](https://hl7.org/fhir/R4/organization.html#search)。 



