package com.produitvente.demo.Controllers;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.GetMapping;


@RestController
@RequestMapping("/demo")
public class HomeControllers {
    

    @GetMapping("/protected")
    public String helloSecure() {
        return "Hello tout le monde (proteger) !";
    }

   
    @GetMapping("/public")
    public String helloUnSecure() {
        return "Hello tout le monde (non proteger)!";
    }
    

    @GetMapping("/user")
    public String helloUser() {
        return "Hello tout le monde (user)!";
    }

    @GetMapping("/admin")
    public String helloAdmin() {
        return "Hello tout le monde (admin)!";
    }
}
