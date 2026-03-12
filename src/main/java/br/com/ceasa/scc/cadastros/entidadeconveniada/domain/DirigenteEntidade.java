package br.com.ceasa.scc.cadastros.entidadeconveniada.domain;

import jakarta.persistence.*;
import lombok.*;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "scc_dirigente_entidade")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DirigenteEntidade {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "entidade_conveniada_id", nullable = false)
    private EntidadeConveniada entidadeConveniada;

    @Column(nullable = false, length = 255)
    private String nome;

    @Column(nullable = false, length = 14)
    private String cpf;

    @Column(length = 120)
    private String cargo;

   
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