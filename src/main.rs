use actix_web::{get, App, HttpResponse, HttpServer, Responder};

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
    println!("Server starting on http://0.0.0.0:8080");

    HttpServer::new(|| {
        App::new()
            .service(hello)
            .service(health)
    })
    .bind("0.0.0.0:8080")?
    .run()
    .await
}
