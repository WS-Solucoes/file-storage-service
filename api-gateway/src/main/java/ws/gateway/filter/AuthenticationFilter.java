package ws.gateway.filter;

import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.util.AntPathMatcher;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.cloud.gateway.support.ServerWebExchangeUtils;
import org.springframework.web.server.ServerWebExchange;

import reactor.core.publisher.Mono;

@Component
public class AuthenticationFilter implements GlobalFilter, Ordered {

    private static final AntPathMatcher PATH_MATCHER = new AntPathMatcher();
    private static final List<String> PUBLIC_UNIDADE_GESTORA_PATTERNS = List.of(
            "/common/api/v1/unidadeGestora/**",
            "/common/api/v1/unidadeGestora/municipio/**");

    private final WebClient authClient;

    private final List<String> unsecuredPatterns;

    public AuthenticationFilter(WebClient.Builder webClientBuilder,
                                @Value("${ws.gateway.auth-service-id:common-service}") String authServiceId,
                                @Value("${ws.gateway.unsecured-patterns:/api/auth/**,/actuator/**,/docs/**,/swagger-ui/**}") List<String> unsecuredPatterns) {
        this.authClient = webClientBuilder.baseUrl("http://" + authServiceId).build();
        this.unsecuredPatterns = unsecuredPatterns;
    }

    @Override
    public int getOrder() {
        return -100;
    }

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();
        String path = request.getURI().getPath();

        if (ServerWebExchangeUtils.isAlreadyRouted(exchange)) {
            return chain.filter(exchange);
        }

        if (HttpMethod.OPTIONS.equals(request.getMethod()) || isUnsecuredPath(path)) {
            return chain.filter(exchange);
        }

        List<String> authorizationHeaders = request.getHeaders().get(HttpHeaders.AUTHORIZATION);
        if (authorizationHeaders == null || authorizationHeaders.isEmpty()) {
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            exchange.getResponse().getHeaders().setContentType(MediaType.APPLICATION_JSON);
            return exchange.getResponse().setComplete();
        }

        String token = authorizationHeaders.get(0);

        return authClient.get()
                .uri(uriBuilder -> uriBuilder.path("/api/auth/validate").build())
                .header(HttpHeaders.AUTHORIZATION, token)
                .retrieve()
                .toBodilessEntity()
                .then(chain.filter(exchange))
                .onErrorResume(WebClientResponseException.class, ex -> {
                    HttpStatusCode statusCode = ex.getStatusCode();
                    if (statusCode.equals(HttpStatus.UNAUTHORIZED) || statusCode.equals(HttpStatus.FORBIDDEN)) {
                        exchange.getResponse().setStatusCode(statusCode);
                        return exchange.getResponse().setComplete();
                    }
                    exchange.getResponse().setStatusCode(HttpStatus.SERVICE_UNAVAILABLE);
                    return exchange.getResponse().setComplete();
                })
                .onErrorResume(ex -> {
                    exchange.getResponse().setStatusCode(HttpStatus.SERVICE_UNAVAILABLE);
                    return exchange.getResponse().setComplete();
                });
    }

    private boolean isUnsecuredPath(String path) {
        return unsecuredPatterns.stream().anyMatch(pattern -> PATH_MATCHER.match(pattern, path))
                || PUBLIC_UNIDADE_GESTORA_PATTERNS.stream().anyMatch(pattern -> PATH_MATCHER.match(pattern, path));
    }
}
