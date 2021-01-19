# Tips

## Wrong clock associations

Sometimes Vivado associates wrong clocks with interfaces. In this case, remove the wrongly associated clock, add it again manually and set the association yourself. Example below.

```
#Clk is associated wrongly, so we remove and re-add it
remove_autodetected_interface Clk
add_clock_in_interface Clk

#Set the association manually
set_interface_clock s00_axi s00_axi_aclk
```

## File versioning in Git 

Following generated files should be added to the Git repository:

```
├── bd
│   └── bd.tcl
├── component.xml
└── xgui
    └── spi_simple_v1_2.tcl
```
