// 使用正则表达式校验医疗机构执业许可证登记号格式
Invariant:   miplrn-encodingrule-format
Description: "医疗机构执业许可证登记号为字符串，其中只包括数字，大写字母和连字符'-'"
Severity:    #error
Expression:  "value.matches('^[0-9A-Z-]+$')"
XPath:       "f:value"

// 使用正则表达式校验卫生机构（组织）代码格式
Invariant:   hcoc-encodingrule-format
Description: "卫生机构（组织）代码为22位或23位字符串，其中只包括数字，大写字母和连字符'-'"
Severity:    #error
Expression:  "value.matches('^[0-9A-Z-]{22,23}$')"
XPath:       "f:value"

// 扩展字段，使用WS 218-2002 卫生机构（组织）分类与代码记录卫生机构类型
Extension: HealthcareInstitutionsTypeExtension
Id: hc-mdm-healthcareinstitutionstype
Title: "卫生机构（组织）分类"
Description: "使用WS 218-2002 卫生机构（组织）分类与代码"
Context: HealthcareOrganization
* value[x] only Coding
* value[x] from HealthcareInstitutionsTypeVS (required)

// 扩展字段，记录中国医院三级评审等级
Extension: HospitalLevelExtension
Id: hc-mdm-hospitallevel
Title: "中国医院三级评审等级"
Description: "中国医院三级评审等级"
Context: HealthcareOrganization
* value[x] only Coding
* value[x] from CNHospitalLevelVS (required)

// 扩展字段，记录医院管理类型
Extension: HospitalManagementTypeExtension
Id: hc-mdm-hospitalmanagementype
Title: "医院管理类型"
Description: "医院管理类型，使用WS 218-2002 卫生机构（组织）分类与代码中附录B，机构分类管理代码表作为标准。"
Context: HealthcareOrganization
* value[x] only Coding
* value[x] from CNHospitalManagementTypeVS (required)

// 扩展字段，记录次要组织机构类型信息
Extension: SecondaryHealthcareInstitutionsInfoExtension
Id: hc-mdm-secondaryhealthcareinstitutionsinfo
Title: "次要组织机构信息"
Description: "包含次要组织机构名称与类型两个属性，其中次要组织机构类型需使用WS 218-2002 卫生机构（组织）分类与代码。次要组织机构名称为医疗机构除与统一社会信用代码对应的名称外还具有的其他具备医疗服务职能的官方名称，如某市胸痛中心，某市急救中心等，与非官方的别名不同。"
Context: HealthcareOrganization
* extension contains
    secondaryType 0..1 MS and
    secondaryName 0..1
* extension[secondaryType] ^short = "次要组织机构类型"
* extension[secondaryType].value[x] only Coding
* extension[secondaryType].value[x] from HealthcareInstitutionsTypeVS (required) // OmbEthnicityCategories is a value set defined by US Core
* extension[secondaryName] ^short = "次要组织机构名称。次要组织机构名称为医疗机构除与统一社会信用代码对应的名称外还具有的其他具备医疗服务职能的官方名称，如某市胸痛中心，某市急救中心等，与非官方的别名不同。"
* extension[secondaryName].value[x] only string

// HealthcareOrganization Profile
Profile: HealthcareOrganization
Id: hc-healthcare-organization
Title: "卫生机构主数据"
Parent: MDMOrganization
Description: "中国卫生机构主数据数据模型"
* meta.profile ^short = "资源所引用的profile"
* meta.profile ^comment = "在新增、修改等操作中，卫生机构主数据需引用profile，格式为http://[标准发布地址]/StructureDefinition/hc-healthcare-organization|0.1.0"
* extension[EconomicIndustryClassificationExtension] 1..1 MS
* extension contains HealthcareInstitutionsTypeExtension named HealthcareInstitutionsTypeExtension 1..1 MS
* extension contains HospitalLevelExtension named HospitalLevelExtension 0..1 MS
* extension contains HospitalManagementTypeExtension named HospitalManagementTypeExtension 1..1 MS
* extension contains SecondaryHealthcareInstitutionsInfoExtension named SecondaryHealthcareInstitutionsInfoExtension 0..* MS
// identifier contains规则
* identifier contains
    miplrn 1..1 MS and 
    hcoc 0..1 MS
// 医疗机构执业许可证登记号切片
* identifier[miplrn] ^short = "医疗机构执业许可证登记号"
* identifier[miplrn] ^definition = "医疗机构执业许可证登记号"
* identifier[miplrn].use = $iduse#official
* identifier[miplrn].type = ChineseIdentifierTypeCS#MIPLRN
* identifier[miplrn].period ^short = "医疗机构执业许可证登记号有效期"
* identifier[miplrn].period ^definition = "医疗机构执业许可证登记号有效期，含开始时间和结束时间两部分。"
// 对医疗机构执业许可证登记号添加约束
* identifier[miplrn] obeys miplrn-encodingrule-format
// 卫生机构（组织）代码切片
* identifier[hcoc] ^short = "卫生机构（组织）代码"
* identifier[hcoc] ^definition = "卫生机构（组织）代码，遵循WS 218-2002 卫生机构（组织）分类中的要求。"
* identifier[hcoc].use = $iduse#official
* identifier[hcoc].type = ChineseIdentifierTypeCS#HCOC
// 对卫生机构（组织）代码添加约束
* identifier[hcoc] obeys hcoc-encodingrule-format
// 引用主机构
* partOf ^short = "主机构"
* partOf ^comment = "引用主机构，形成分支机构与主机构的多对一关联，例如分院区引用主院区。"
// contact字段切片，用于指定组织负责人或负责人等
* contact ^slicing.discriminator.type = #value
* contact ^slicing.discriminator.path = "purpose"
* contact ^slicing.rules = #open
* contact ^slicing.ordered = false 
* contact ^slicing.description = "contact字段切片，用于指定组织负责人或负责人等"
// 更改负责人类型值集
* contact.purpose from CNContactorTypeVS
// telecom contains规则
* contact contains
    responsible 0..1 MS
// 负责人切片
* contact[responsible] ^short = "负责人"
* contact[responsible] ^definition = "组织机构负责人"
* contact[responsible].purpose = ChineseContactorTypeCS#RES
* contact[responsible].name ^short = "负责人姓名"
// contact[responsible].telecom字段切片，用于指定负责人电话
* contact[responsible].telecom ^slicing.discriminator.type = #value
* contact[responsible].telecom ^slicing.discriminator.path = "system"
* contact[responsible].telecom ^slicing.rules = #open
* contact[responsible].telecom ^slicing.ordered = false 
* contact[responsible].telecom ^slicing.description = "contact[responsible].telecom字段切片，用于指定负责人电话。"
// contact[responsible].telecom contains规则
* contact[responsible].telecom contains
    phone 0..1 MS
// 负责人电话号码切片
* contact[responsible].telecom[phone] ^short = "负责人电话号码"
* contact[responsible].telecom[phone] ^definition = "负责人电话号码"
* contact[responsible].telecom[phone].system = http://hl7.org/fhir/contact-point-system#phone
* contact[responsible].telecom[phone].use = $conuse#work 


Instance: ChangningFengxiaoDistrictCentralHospital
InstanceOf: HealthcareOrganization
Description: "长宁市奉孝区中心医院(虚拟医院)"
//* meta.profile = "http://fhir.cq.hc/StructureDefinition/hc-healthcare-organization|0.1.0"
* active = true 
* type = OrganizationTypeCS#121 "事业单位法人"
* name = "长宁市奉孝区中心医院"
* extension[AdministrativeDivisionExtension].valueCoding = CQAdministrativeDivisionCS#500105 "江北区"
* extension[StreetDivisionExtension].valueCoding = CQStreetDivisionCS#500105011 "石马河街道"
* extension[HealthcareInstitutionsTypeExtension].valueCoding = HealthcareInstitutionsTypeCS#A100 "综合医院"
* extension[HospitalLevelExtension].valueCoding = CNHospitalLevelCS#2 "三级甲等"
* extension[EconomicIndustryClassificationExtension].valueCoding = NationalEconomicIndustryClassificationCS#110 "国有全资"
* extension[HospitalManagementTypeExtension].valueCoding = CNHospitalManagementTypeCS#1 "非营利性医疗机构"
* extension[SecondaryHealthcareInstitutionsInfoExtension][0].extension[secondaryType].valueCoding = HealthcareInstitutionsTypeCS#E100 "急救中心"
* extension[SecondaryHealthcareInstitutionsInfoExtension][0].extension[secondaryName].valueString = "长宁市急救中心"
* extension[SupervisedByExtension].valueReference.type = "Organization"
* extension[SupervisedByExtension].valueReference.identifier.type = ChineseIdentifierTypeCS#MOI "机构主索引号码"
* extension[SupervisedByExtension].valueReference.identifier.value = "1638748745645060"
* extension[SupervisedByExtension].valueReference.display = "重庆市渝中区卫生健康委员会"
* extension[OperatingStatusExtension].valueCoding = OperatingStatusCS#0 "开业"
* telecom[phone].system = http://hl7.org/fhir/contact-point-system#phone
* telecom[phone].use = $conuse#work
* telecom[phone].value = "+86-23-65100171"
* telecom[email].system = http://hl7.org/fhir/contact-point-system#email
* telecom[email].use = $conuse#work
* telecom[email].value = "abc@cnu.org"
* telecom[website].system = http://hl7.org/fhir/contact-point-system#url
* telecom[website].use = $conuse#work
* telecom[website].value = "https://abc.bj.org.cn"
* identifier[miplrn].use = $iduse#official
* identifier[miplrn].type = ChineseIdentifierTypeCS#MIPLRN "医疗机构执业许可证登记号"
* identifier[miplrn].value = "PRN561106-211311"
* identifier[miplrn].period.start = "2022-02-07"
* identifier[miplrn].period.end = "2027-02-07"
* identifier[hcoc].use = $iduse#official
* identifier[hcoc].type = ChineseIdentifierTypeCS#HCOC "卫生机构（组织）代码"
* identifier[hcoc].value = "PRN561106-2113118450-1"
* identifier[moi].use = $iduse#official
* identifier[moi].type = ChineseIdentifierTypeCS#MOI "机构主索引号码"
* identifier[moi].value = "82783739457838954"
* identifier[uscc].use = $iduse#official
* identifier[uscc].type = ChineseIdentifierTypeCS#USCC "统一社会信用代码"
* identifier[uscc].value = "12330000470051726F"
* address[0].extension[OrganizationGISExtension].extension[longitude].valueDecimal = 106.55
* address[0].extension[OrganizationGISExtension].extension[latitude].valueDecimal = 29.55
* address[0].use = http://hl7.org/fhir/address-use#work
* address[0].type = http://hl7.org/fhir/address-type#physical
* address[0].line = "XX省长宁市奉孝区健康路1号"
* address[0].postalCode = "400210"
* contact[responsible].purpose = ChineseContactorTypeCS#RES
* contact[responsible].name.text = "张无忌"
* contact[responsible].telecom[phone].system = http://hl7.org/fhir/contact-point-system#phone
* contact[responsible].telecom[phone].use = $conuse#work
* contact[responsible].telecom[phone].value = "+86-18502032240"


Instance: ChangningFengxiaoDistrictCentralHospitalBranch
InstanceOf: HealthcareOrganization
Description: "长宁市奉孝区中心医院龙翔路分院(虚拟分院区)。"
//* meta.profile = "http://fhir.cq.hc/StructureDefinition/hc-healthcare-organization|0.1.0"
* active = true 
* type = OrganizationTypeCS#121 "事业单位法人"
* name = "长宁市奉孝区中心医院龙翔路分院"
* extension[AdministrativeDivisionExtension].valueCoding = CQAdministrativeDivisionCS#500117 "合川区"
* extension[StreetDivisionExtension].valueCoding = CQStreetDivisionCS#500117103 "官渡镇"
* extension[HealthcareInstitutionsTypeExtension].valueCoding = HealthcareInstitutionsTypeCS#A516 "胸科医院"
* extension[HospitalLevelExtension].valueCoding = CNHospitalLevelCS#5 "二级甲等"
* extension[EconomicIndustryClassificationExtension].valueCoding = NationalEconomicIndustryClassificationCS#110 "国有全资"
* extension[HospitalManagementTypeExtension].valueCoding = CNHospitalManagementTypeCS#1 "非营利性医疗机构"
* extension[SupervisedByExtension].valueReference.type = "Organization"
* extension[SupervisedByExtension].valueReference.identifier.type = ChineseIdentifierTypeCS#MOI "机构主索引号码"
* extension[SupervisedByExtension].valueReference.identifier.value = "1638748745645060"
* extension[SupervisedByExtension].valueReference.display = "重庆市渝中区卫生健康委员会"
* extension[OperatingStatusExtension].valueCoding = OperatingStatusCS#1 "筹建"
* telecom[phone].system = http://hl7.org/fhir/contact-point-system#phone
* telecom[phone].use = $conuse#work
* telecom[phone].value = "+86-23-65203427"
* identifier[miplrn].use = $iduse#official
* identifier[miplrn].type = ChineseIdentifierTypeCS#MIPLRN "医疗机构执业许可证登记号"
* identifier[miplrn].value = "54699457698765"
* identifier[miplrn].period.start = "2023-10-21"
* identifier[miplrn].period.end = "2031-10-20"
* identifier[hcoc].use = $iduse#official
* identifier[hcoc].type = ChineseIdentifierTypeCS#HCOC "卫生机构（组织）代码"
* identifier[hcoc].value = "74085017434152212C2101"
* identifier[moi].use = $iduse#official
* identifier[moi].type = ChineseIdentifierTypeCS#MOI "机构主索引号码"
* identifier[moi].value = "82783739457838954"
* address[0].extension[OrganizationGISExtension].extension[longitude].valueDecimal = 106.58
* address[0].extension[OrganizationGISExtension].extension[latitude].valueDecimal = 29.51
* address[0].use = http://hl7.org/fhir/address-use#work
* address[0].type = http://hl7.org/fhir/address-type#physical
* address[0].line = "XX省长宁市奉孝区龙翔路42号"
* address[0].postalCode = "400210"
* contact[responsible].purpose = ChineseContactorTypeCS#RES
* contact[responsible].name.text = "李广利"
* contact[responsible].telecom[phone].system = http://hl7.org/fhir/contact-point-system#phone
* contact[responsible].telecom[phone].use = $conuse#work
* contact[responsible].telecom[phone].value = "+86-18412594521"
* partOf.reference = "http://localhost/fhir/r4/Organization/2"
* partOf.type = "Organization"
* partOf.identifier.type = ChineseIdentifierTypeCS#MOI "机构主索引号码"
* partOf.identifier.value = "82783739457838954"
* partOf.display = "长宁市奉孝区中心医院"






