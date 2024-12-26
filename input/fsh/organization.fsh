// 使用正则表达式校验统一社会信用代码格式（18）
Invariant:   uscc-encodingrule-18
Description: "源于GB 32100-2015 《法人和其他组织统一社会信用代码编码规则》，中国统一社会信用代码长度为18位。第一位为登记管理部门代码[1,5,9,Y]，第二位为机构类别代码[1,2,3,9]，第3~8位遵循GB/T 2260-2007《中华人民共和国行政区划代码》，[0-9]数字格式；第9~17位遵循GB 11714-1997《全国组织机构代码编制规则》，为[0-9][A-Z]；第18位为校验码，遵循GB/T 17710-2008《信息技术 安全技术 校验字符系统》，为[0-9][A-Z][*]。"
Severity:    #error
Expression:  "value.matches('^[159Y]{1}[1239]{1}[0-9]{6}[0-9A-Z]{9}[0-9A-Z*]{1}$')"
XPath:       "f:value"

// 使用正则表达式校验重庆邮政编码
Invariant:   postalcode-chongqing-format
Description: "重庆地区邮政编码，6位数字，必须以40开头。"
Severity:    #error
Expression:  "postalCode.matches('^40[0-9]{4}$')"
XPath:       "f:postalCode"

// 扩展字段，记录次要组织机构类型信息
Extension: OrganizationGISExtension
Id: hc-mdm-organizationggis
Title: "组织机构地理位置坐标"
Description: "组织机构地理位置坐标，以10进制WGS84经纬度表示"
Context: Address
* extension contains
    longitude 0..1 MS and
    latitude 0..1
* extension[longitude] ^short = "经度，以10进制WGS84经度表示"
* extension[longitude].value[x] only decimal
* extension[latitude] ^short = "纬度，以10进制WGS84纬度表示"
* extension[latitude].value[x] only decimal

// 扩展字段，记录所属行政区域
Extension: AdministrativeDivisionExtension
Id: hc-mdm-administrativedivision
Title: "民政区划(区县)"
Description: "民政区划(区县)"
Context: MDMOrganization
* value[x] only Coding
* value[x] from CQAdministrativeDivisionVS (required)

// 扩展字段，记录重庆乡镇街道级行政区划
Extension: StreetDivisionExtension
Id: hc-mdm-streetdivision
Title: "民政区划(街道)"
Description: "民政区划(街道)"
Context: MDMOrganization
* value[x] only Coding
* value[x] from CQStreetDivisionVS (required)

// 扩展字段，记录组织机构经济类型
Extension: EconomicIndustryClassificationExtension
Id: hc-mdm-economicindustryclassification
Title: "经济类型分类"
Description: "经济类型分类"
Context: MDMOrganization
* value[x] only Coding
* value[x] from CNNationalEconomicIndustryClassificationVS

// 扩展字段，引用上级管理机构
Extension: SupervisedByExtension
Id: hc-mdm-supervisedby
Title: "上级监管机构"
Description: "由被监管机构引用监管机构，例如县医院引用县卫健委。"
Context: MDMOrganization
* value[x] only Reference

// 扩展字段，记录机构运营状态
Extension: OperatingStatusExtension
Id: hc-mdm-operatingstatus
Title: "机构运营状态"
Description: "机构运营状态"
Context: MDMOrganization
* value[x] only Coding
* value[x] from OperatingStatusVS

// Organization Profile
Profile: MDMOrganization
Id: hc-mdm-organization
Title: "组织机构主数据"
Parent: Organization
Description: "中国组织机构主数据数据模型。本标准所指的组织，是指为实现某种形式的集体行动而组成的正式或非正式认可的人员或组织团体。包括公司、机构、企业、部门、社区团体、医疗实践团体、付款人/承保人等。"
* meta.id ^short = "资源物理id"
* meta.id ^comment = "对于新增操作，资源物理id由服务器指定，不需要赋值；对于更新操作，则应赋值。"
* meta.profile ^short = "资源所引用的profile"
* meta.profile ^comment = "在新增、修改等操作中，组织机构主数据需引用profile，格式为http://[标准发布地址]/StructureDefinition/hc-mdm-organization|0.1.0"
* meta.profile 1..1 MS
* extension contains AdministrativeDivisionExtension named AdministrativeDivisionExtension 1..1 MS
* extension contains StreetDivisionExtension named StreetDivisionExtension 0..1 MS
* extension contains EconomicIndustryClassificationExtension named EconomicIndustryClassificationExtension 0..1 MS
* extension contains SupervisedByExtension named SupervisedByExtension 0..1 MS
* extension contains OperatingStatusExtension named OperatingStatusExtension 1..1 MS
* type ^short = "机构类型"
* type ^comment = "以国家标准GB/T 20091-2021 组织机构类型表述"
* type from OrganizationTypeVS
* name ^short = "与统一社会信用代码对应的组织机构名称"
* name ^comment = "如机构具有其他名称，应使用别名（alias）表述"
* name 1..1 MS 
* alias ^short = "除统一社会信用代码对应的组织机构名称之外的所有别名，例如简称或其他非官方名称"
// 更改identifier类型来源，使之可以兼容更多证件类型如统一社会信用代码，主数据索引号等
* identifier.type from CNIdentifierTypeVS
* identifier.type ^comment = "更改identifier类型来源，使之可以兼容更多证件类型如统一社会信用代码，主数据索引号等"
// identifier字段切片，用于指定统一社会信用代码，主索引号码和组织机构执业许可证登记号等
* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "type"
* identifier ^slicing.rules = #open
* identifier ^slicing.ordered = false
* identifier ^slicing.description = "基于identifier类型的切片，使之可容纳组织机构所持统一社会信用代码"
// identifier contains规则
* identifier contains
    moi 0..1 MS and
    uscc 0..1 MS
// 机构主索引切片
* identifier[moi] ^short = "机构主索引号码"
* identifier[moi] ^definition = "机构主索引号码，由主数据管理平台分配和维护"
* identifier[moi].use = $iduse#official
* identifier[moi].type = ChineseIdentifierTypeCS#MOI
// 统一社会信用代码切片
* identifier[uscc] ^short = "统一社会信用代码"
* identifier[uscc] ^definition = "统一社会信用代码，必须符合格式约束"
* identifier[uscc].use = $iduse#official
* identifier[uscc].type = ChineseIdentifierTypeCS#USCC
// 对社会信用代码字段添加约束
* identifier[uscc] obeys uscc-encodingrule-18
// telecom字段切片，用于指定组织电话和电子邮箱
* telecom ^slicing.discriminator.type = #value
* telecom ^slicing.discriminator.path = "system"
* telecom ^slicing.rules = #open
* telecom ^slicing.ordered = false 
* telecom ^slicing.description = "telecom字段切片，用于指定组织电话和电子邮箱"
// telecom contains规则
* telecom contains
    phone 1..1 MS and
    email 0..1 MS and
    website 0..1 MS
// 组织机构电话号码切片
* telecom[phone] ^short = "组织机构电话号码"
* telecom[phone] ^definition = "组织机构电话号码"
* telecom[phone].system = http://hl7.org/fhir/contact-point-system#phone
* telecom[phone].use = $conuse#work 
// 组织机构电子邮件地址切片
* telecom[email] ^short = "组织机构电子邮件地址"
* telecom[email] ^definition = "组织机构电子邮件地址"
* telecom[email].system = http://hl7.org/fhir/contact-point-system#email
* telecom[email].use = $conuse#work 
// 组织机构网站地址切片
* telecom[website] ^short = "组织机构网站地址"
* telecom[website] ^definition = "组织机构网站地址"
* telecom[website].system = http://hl7.org/fhir/contact-point-system#url
* telecom[website].use = $conuse#work
// 组织机构经纬度
* address.extension contains OrganizationGISExtension named OrganizationGISExtension 0..1 MS
* address.line ^short = "详细地址"
* address.line ^comment = "以字符串记录"
* address.postalCode ^short = "邮政编码"
* address.postalCode ^comment = "邮政编码"
// 对邮编添加约束
* address obeys postalcode-chongqing-format

Instance: ChongqingHealthCommission
InstanceOf: MDMOrganization
Description: "重庆市卫生健康委员会"
//* meta.profile = "http://fhir.cq.hc/StructureDefinition/hc-mdm-organization|0.1.0"
* active = true 
* type = OrganizationTypeCS#121 "事业单位法人"
* name = "重庆市卫生健康委员会"
* extension[AdministrativeDivisionExtension].valueCoding = CQAdministrativeDivisionCS#500112 "渝北区"
* extension[StreetDivisionExtension].valueCoding = CQStreetDivisionCS#500112005 "龙山街道"
* extension[OperatingStatusExtension].valueCoding = OperatingStatusCS#0 "开业"
* telecom[phone].system = http://hl7.org/fhir/contact-point-system#phone
* telecom[phone].use = $conuse#work
* telecom[phone].value = "+86-23-67706707"
* telecom[email].system = http://hl7.org/fhir/contact-point-system#email
* telecom[email].use = $conuse#work
* telecom[email].value = "abc@cnu.org"
* telecom[website].system = http://hl7.org/fhir/contact-point-system#url
* telecom[website].use = $conuse#work
* telecom[website].value = "https://wsjkw.cq.gov.cn"
* identifier[moi].use = $iduse#official
* identifier[moi].type = ChineseIdentifierTypeCS#MOI "机构主索引号码"
* identifier[moi].value = "82783739457838954"
* identifier[uscc].use = $iduse#official
* identifier[uscc].type = ChineseIdentifierTypeCS#USCC "统一社会信用代码"
* identifier[uscc].value = "11500000MB1670604W"
* address[0].extension[OrganizationGISExtension].extension[longitude].valueDecimal = 106.50520499999993
* address[0].extension[OrganizationGISExtension].extension[latitude].valueDecimal = 29.593906000000015
* address[0].use = http://hl7.org/fhir/address-use#work
* address[0].type = http://hl7.org/fhir/address-type#physical
* address[0].line = "重庆市渝北区旗龙路6号"
* address[0].postalCode = "401147"

Instance: ChongqingYuzhongHealthCommission
InstanceOf: MDMOrganization
Description: "重庆市渝中区卫生健康委员会"
//* meta.profile = "http://fhir.cq.hc/StructureDefinition/hc-mdm-organization|0.1.0"
* active = true 
* type = OrganizationTypeCS#121 "事业单位法人"
* name = "重庆市渝中区卫生健康委员会"
* extension[AdministrativeDivisionExtension].valueCoding = CQAdministrativeDivisionCS#500103 "渝中区"
* extension[StreetDivisionExtension].valueCoding = CQStreetDivisionCS#500103001 "七星岗街道"
* extension[SupervisedByExtension].valueReference.type = "Organization"
* extension[SupervisedByExtension].valueReference.identifier.type = ChineseIdentifierTypeCS#MOI "机构主索引号码"
* extension[SupervisedByExtension].valueReference.identifier.value = "82783739457838954"
* extension[SupervisedByExtension].valueReference.display = "重庆市卫生健康委员会"
* extension[OperatingStatusExtension].valueCoding = OperatingStatusCS#0 "开业"
* telecom[phone].system = http://hl7.org/fhir/contact-point-system#phone
* telecom[phone].use = $conuse#work
* telecom[phone].value = "+86-23-63765146"
* telecom[email].system = http://hl7.org/fhir/contact-point-system#email
* telecom[email].use = $conuse#work
* telecom[email].value = "yzqwsj@163.com"
* telecom[website].system = http://hl7.org/fhir/contact-point-system#url
* telecom[website].use = $conuse#work
* telecom[website].value = "http://www.cqyz.gov.cn/bm_229/qwsjkw/zwgk_97157/"
* identifier[moi].use = $iduse#official
* identifier[moi].type = ChineseIdentifierTypeCS#MOI "机构主索引号码"
* identifier[moi].value = "1638748745645060"
* identifier[uscc].use = $iduse#official
* identifier[uscc].type = ChineseIdentifierTypeCS#USCC "统一社会信用代码"
* identifier[uscc].value = "11500103MB1849823N"
* address[0].extension[OrganizationGISExtension].extension[longitude].valueDecimal = 106.56887499999993
* address[0].extension[OrganizationGISExtension].extension[latitude].valueDecimal = 29.55277699999998
* address[0].use = http://hl7.org/fhir/address-use#work
* address[0].type = http://hl7.org/fhir/address-type#physical
* address[0].line = "重庆市渝中区和平路管家巷9号"
* address[0].postalCode = "400010"
