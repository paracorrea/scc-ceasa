package br.com.ceasa.scc.cadastros.despesa.domain;


import jakarta.persistence.*;
import lombok.*;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "scc_despesa")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Despesa {

    @Id
    @GeneratedValue
    private UUID id;

    @Column(nullable = false, length = 50)
    private String codigo;

    @Column(nullable = false, length = 255)
    private String nome;

    @Column(nullable = false)
    private Integer ordem;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    @PrePersist
    void prePersist() {
        OffsetDateTime now = OffsetDateTime.now();
        if (createdAt == null) createdAt = now;
        if (updatedAt == null) updatedAt = now;
    }

    @PreUpdate
    void preUpdate() {
        updatedAt = OffsetDateTime.now();
    }
}