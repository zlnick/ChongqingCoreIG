本标准中包含如下示例。  
用户查看时应当注意，本次发布的标准版本只支持JSON格式的表达方式，XML格式仅为示例和作为测试用途，不作为生产环境开放的格式。  

## 组织机构主数据示例  

### [重庆市卫生健康委员会](Organization-ChongqingHealthCommission.html)    

### [重庆市渝中区卫生健康委员会](Organization-ChongqingYuzhongHealthCommission.html)  
可注意到区卫健委通过supervisedby扩展引用市卫健委，以表达行政管理上区卫健委受市卫健委管辖的语义。  


## 卫生机构主数据示例  
### 主院区示例  [长宁市奉孝区中心医院](Organization-ChangningFengxiaoDistrictCentralHospital.html)      

### 分院区示例  [长宁市奉孝区中心医院龙翔路分院](Organization-ChangningFengxiaoDistrictCentralHospitalBranch.html)      

分院通过partOf元素引用主院，以表达分院区与主院区的关系。  
分院与主院关系在数据不同时期采用不同的关联逻辑。  
    
在执行数据标准化时，主院区不能确定获得唯一标识，此时分院区只能通过partOf.reference，引用主院区标准数据的url完成与主院区的关联。  
假设分院区对应的主院区，长宁市奉孝区中心医院，被添加到标准化数据存储中时，由FHIR服务器为其分配的url为http://localhost:52880/csp/healthshare/fhirserver/fhir/r4/Organization/2，其资源id为2，则通过url建立的引用如下所示。      
```json
{
    "partOf": {
        "type": "Organization",
        "reference" : "http://localhost:52880/csp/healthshare/fhirserver/fhir/r4/Organization/2",
        "display": "长宁市奉孝区中心医院"
    }
}
``` 
  
在标准化数据经疑似合并转换为主数据时，所有数据都能获得机构主索引（moi）作为唯一标识，此时需要更新分院区的引用，通过partOf.identifier引用主院区的主索引完成与主院区的关联。
```json
{
    "partOf" : {
    "type" : "Organization",
    "identifier" : {
      "type" : {
        "coding" : [
          {
            "system" : "http://fhir.cq.hc/CodeSystem/identifierType-code-system",
            "code" : "MOI",
            "display" : "机构主索引号码"
          }
        ]
      },
      "value" : "82783739457838954"
    },
    "display" : "长宁市奉孝区中心医院"
  }
}
```   

应当注意partOf的reference元素和identifier可以共存，因此，如下的格式    
```json
{
    "partOf" : {
    "type" : "Organization",
    "reference" : "http://localhost:52880/csp/healthshare/fhirserver/fhir/r4/Organization/2",
    "identifier" : {
      "type" : {
        "coding" : [
          {
            "system" : "http://fhir.cq.hc/CodeSystem/identifierType-code-system",
            "code" : "MOI",
            "display" : "机构主索引号码"
          }
        ]
      },
      "value" : "82783739457838954"
    },
    "display" : "长宁市奉孝区中心医院"
  }
}
```   
是合法的引用。



 




