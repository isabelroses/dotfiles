{
    isNvidia,
    isLaptop,
    ...
}: {
    isabel = {
        hyprland = {
            enable = true;
            withNvidia = isNvidia;
            onLaptop = isLaptop;
        };
    };
    catppuccin ={
        flavour = "mocha";
    };
}