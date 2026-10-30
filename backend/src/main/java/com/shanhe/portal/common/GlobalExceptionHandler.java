package com.shanhe.portal.common;

import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * 把校验错误、业务异常和未预期错误收成统一的 JSON。
 * 业务错误保持 HTTP 200，由 body.code 表达；401/403 保留真实状态码，方便前端跳转登录。
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BizException.class)
    public ResponseEntity<R<Void>> biz(BizException ex) {
        if (ex.getCode() == 401 || ex.getCode() == 403) {
            return ResponseEntity.status(ex.getCode()).body(R.fail(ex.getCode(), ex.getMessage()));
        }
        return ResponseEntity.ok(R.fail(ex.getCode(), ex.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public R<Void> valid(MethodArgumentNotValidException ex) {
        FieldError field = ex.getBindingResult().getFieldError();
        String message = field == null ? "参数不合法" : field.getDefaultMessage();
        return R.fail(400, message);
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public R<Void> unreadable(HttpMessageNotReadableException ex) {
        return R.fail(400, "请求体格式不正确");
    }

    @ExceptionHandler(DuplicateKeyException.class)
    public R<Void> duplicate(DuplicateKeyException ex) {
        return R.fail(400, "数据已存在，请检查名称或账号是否重复");
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public R<Void> integrity(DataIntegrityViolationException ex) {
        log.warn("数据约束冲突: {}", ex.getMostSpecificCause().getMessage());
        return R.fail(400, "操作失败，请检查关联数据是否仍被引用");
    }

    @ExceptionHandler(Exception.class)
    public R<Void> unknown(Exception ex) {
        log.error("未处理异常", ex);
        return R.fail(500, "服务器开小差了，请稍后再试");
    }
}
