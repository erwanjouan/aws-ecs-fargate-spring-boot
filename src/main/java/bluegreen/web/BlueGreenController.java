package bluegreen.web;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class BlueGreenController {

    @Value("${display_color}")
    private String color;

    @GetMapping("/")
    public String page(Model model){
        model.addAttribute("color", color);
        return "page";
    }
}
