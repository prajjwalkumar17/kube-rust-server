use actix_web::{get, App, HttpResponse, HttpServer, Responder};
// const URL:&str = "192.168.29.100:8080";
const URL:&str = "0.0.0.0:8080";

#[get("/")]
async fn hello() -> impl Responder {
    HttpResponse::Ok().body("Hello from Kubernetes on NixOS with Podman!")
}

#[get("/health")]
async fn health() -> impl Responder {
    HttpResponse::Ok().body("Healthy")
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    println!("Server starting on {}",URL);

    HttpServer::new(|| {
        App::new()
            .service(hello)
            .service(health)
    })
    .bind(URL)?
    .run()
    .await
}
