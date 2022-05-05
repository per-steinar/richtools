
Import-Module PowerHTML

$target = "https://docs.jboss.org/richfaces/nightly_4_5_X/vdldoc/"
$outputDir = "out"

$extention = ".html"

$aj4List = @(
    "commandLink",
    "commandButton",
    "poll",
    "log",
    "attachQueue",
    "repeat",
    "mediaOutput",
    "region",
    "queue",
    "jsFunction",
    "outputPanel",
    "status",
    "param",
    "push",
    "actionListener",
    "ajax")

$richList = @(
    "select",
    "chartSeries",
    "accordionItem",
    "panelMenuGroup",
    "tabPanel",
    "panelMenuItem",
    "togglePanel",
    "editor",
    "message",
    "hotKey",
    "accordion",
    "progressBar",
    "tooltip",
    "dropDownMenu",
    "messages",
    "dataGrid",
    "dataTable",
    "notifyStack",
    "pickList",
    "inputNumberSlider",
    "chartYAxis",
    "dragSource",
    "dragIndicator",
    "treeModelRecursiveAdaptor",
    "jQuery",
    "dropTarget",
    "notifyMessages",
    "menuSeparator",
    "list",
    "togglePanelItem",
    "treeModelAdaptor",
    "menuItem",
    "chartLegend",
    "dataScroller",
    "inplaceSelect",
    "panelMenu",
    "collapsibleSubTable",
    "hashParam",
    "toolbarGroup",
    "contextMenu",
    "extendedDataTable",
    "focus",
    "notify",
    "chartPoint",
    "popupPanel",
    "graphValidator",
    "menuGroup",
    "orderingList",
    "placeholder",
    "fileUpload",
    "treeNode",
    "collapsibleSubTableToggler",
    "collapsiblePanel",
    "tab",
    "chart",
    "columnGroup",
    "tree",
    "notifyMessage",
    "chartXAxis",
    "autocomplete",
    "panel",
    "toolbar",
    "calendar",
    "column",
    "inplaceInput",
    "inputNumberSpinner",
    "treeToggleListener",
    "treeSelectionChangeListener",
    "itemChangeListener",
    "panelToggleListener",
    "componentControl",
    "validator",
    "toggleControl"
)

$namespaces = @(
    @{Key = "rich"; OutputFile = "richfaces4.json"; Tags = $richList},
    @{Key = "a4j"; OutputFile = "richfaces4-a4j.json"; Tags = $aj4List})

foreach ($namespace in $namespaces) {
    $key = $namespace["Key"]
    $filename = $namespace["OutputFile"]
    $file = "./${outputDir}/${filename}"
    $tags = @()
    foreach ($tag in $namespace["Tags"]) {
        Start-Sleep -s 1
        $response = (Invoke-WebRequest -Uri "${target}/${key}/${tag}${extention}" -MaximumRedirection 0)
        $htmlDom = ConvertFrom-HTML $response
        $description = [System.Web.HttpUtility]::HtmlDecode($htmlDom.SelectNodes('//html/body/div/div/ul/li/dl/dd/p').InnerText)
        $tbody = @($htmlDom.SelectNodes('//html/body/div/div/ul/li/table/tbody'))
        $attrs = @()
        foreach ($row in @($tbody[$tbody.Count -1].Elements('tr'))) {
            $cells = @($row.Elements('td'))
            $attrName = $cells[0].ChildNodes[0].ChildNodes[0].ChildNodes[0].InnerText.Trim()
            $attrReq = $cells[1].ChildNodes[0].ChildNodes[0].InnerText.Trim()
            $attrType = $cells[2].ChildNodes[5].InnerText.Trim()
            $attrDesc = $cells[3].ChildNodes[0].InnerText.Trim()
            $attrs += @{
                description = $attrDesc;
                name = $attrName;
                required = $attrReq;
                type = $attrType}
        }
        $tags += @{
            description = $description;
            name = $tag;
            attribute = $attrs
        }
    }
    @{components = @{component = $tags}} | ConvertTo-Json -Depth 5 | Out-File $file
}